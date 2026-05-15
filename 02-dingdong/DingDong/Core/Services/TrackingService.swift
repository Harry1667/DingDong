import Foundation
import Combine
import WidgetKit

@MainActor
final class TrackingService: ObservableObject {
    static let shared = TrackingService()
    private init() {
        tasks = PersistenceService.shared.trackingTasks
            .filter { !$0.isFinished }
        print("[Tracking] 初始化，載入 \(tasks.count) 個任務")
        activateScheduledTasks()
        startPollingTimer()
    }

    /// 同時追蹤上限（依使用者訂閱層級動態變更：free=1 / paid=3）
    static var maxTasks: Int { PersistenceService.shared.userTier.trackLimit }

    @Published private(set) var tasks: [TrackingTask] = []

    private var pollingTimer: Timer?
    private let persistence = PersistenceService.shared
    private let notifications = NotificationService.shared

    // MARK: - 新增追蹤

    @discardableResult
    func startTracking(
        hospital: Hospital,
        progress: ClinicProgress,
        userNumber: Int?,
        threshold: Int,
        scheduledDate: Date? = nil
    ) async throws -> UUID {
        print("[Tracking] startTracking: \(progress.doctorName) @ \(hospital.name)")
        guard tasks.count < Self.maxTasks else {
            print("[Tracking] 已達上限 \(Self.maxTasks) 個任務")
            throw TrackingError.maxTasksReached
        }

        let alreadyTracking = tasks.contains {
            $0.hospitalCode == hospital.code &&
            $0.doctorName == progress.doctorName &&
            $0.clinicRoom == progress.clinicRoom &&
            !$0.isFinished
        }
        guard !alreadyTracking else {
            throw TrackingError.alreadyTracking
        }

        // 判斷是否為未來日期
        let isFuture: Bool
        if let date = scheduledDate {
            isFuture = date > Calendar.current.startOfDay(for: Date())
                    && !Calendar.current.isDateInToday(date)
        } else {
            isFuture = false
        }

        let task = TrackingTask(
            id: UUID(),
            dbId: nil,
            hospitalCode: hospital.code,
            hospitalName: hospital.name,
            department: progress.department,
            doctorName: progress.doctorName,
            clinicRoom: progress.clinicRoom,
            userNumber: userNumber,
            threshold: threshold,
            scheduledDate: isFuture ? scheduledDate : nil,
            currentNumber: progress.currentNumber,
            lastUpdated: Date(),
            status: isFuture ? .scheduled : .active
        )

        var newTask = task
        newTask.numberHistory = [NumberSnapshot(number: progress.currentNumber, timestamp: Date())]
        tasks.append(newTask)
        persist()

        guard !isFuture else { return task.id }

        let capturedToken = NotificationService.shared.apnsToken
        Task.detached(priority: .background) { [task, capturedToken] in
            let request = TrackStartRequest(
                guestId: PersistenceService.shared.guestId,
                hospitalCode: task.hospitalCode,
                department: task.department,
                doctorName: task.doctorName,
                clinicRoom: task.clinicRoom,
                session: nil,
                userNumber: task.userNumber ?? 0,
                apnsToken: capturedToken
            )
            if let response = try? await APIClient.shared.post(
                APIEndpoints.trackStart(),
                body: request
            ) as TrackStartResponse, response.ok, let dbId = response.trackId {
                await MainActor.run {
                    if let idx = self.tasks.firstIndex(where: { $0.id == task.id }) {
                        self.tasks[idx].dbId = dbId
                        self.persist()
                    }
                }
            }
        }
        return task.id
    }

    // MARK: - 停止追蹤

    func stopTracking(taskId: UUID, reason: String = "cancelled") {
        guard let idx = tasks.firstIndex(where: { $0.id == taskId }) else {
            print("[Tracking] stopTracking: 找不到任務 \(taskId)")
            return
        }
        let task = tasks[idx]

        notifications.cancelNotifications(for: taskId)
        saveRecord(task: task, reason: reason)

        if let dbId = task.dbId {
            Task.detached(priority: .background) {
                let req = TrackStopRequest(
                    guestId: PersistenceService.shared.guestId,
                    reason: reason
                )
                _ = try? await APIClient.shared.put(
                    APIEndpoints.trackStop(trackId: dbId),
                    body: req
                ) as TrackStopResponse
            }
        }

        tasks.remove(at: idx)
        persist()
    }

    // MARK: - 預約任務啟動

    // 將到期的預約任務升級為 active
    func activateScheduledTasks() {
        let today = Calendar.current.startOfDay(for: Date())
        var changed = false
        for i in tasks.indices {
            guard tasks[i].status == .scheduled else { continue }
            let taskDay = tasks[i].scheduledDate.map { Calendar.current.startOfDay(for: $0) } ?? today
            if taskDay <= today {
                tasks[i].status = .active
                tasks[i].lastUpdated = Date()
                changed = true
            }
        }
        if changed { persist() }
    }

    // MARK: - 輪詢

    func refreshAllTasks() async {
        activateScheduledTasks()
        let activeTasks = tasks.filter { $0.status == .active }
        guard !activeTasks.isEmpty else { return }

        let hospitalCodes = Set(activeTasks.map { $0.hospitalCode })

        await withTaskGroup(of: Void.self) { group in
            for code in hospitalCodes {
                group.addTask { await self.poll(hospitalCode: code) }
            }
        }
    }

    private func poll(hospitalCode: String) async {
        print("[Tracking] 查詢進度: \(hospitalCode)")
        guard let response = try? await APIClient.shared.get(
            APIEndpoints.progress(hospitalCode: hospitalCode)
        ) as ProgressResponse else {
            print("[Tracking] 查詢失敗或無資料: \(hospitalCode)")
            return
        }

        for i in tasks.indices {
            guard tasks[i].hospitalCode == hospitalCode,
                  tasks[i].status == .active else { continue }

            let task = tasks[i]
            guard let found = response.data.first(where: {
                $0.doctorName == task.doctorName && $0.clinicRoom == task.clinicRoom
            }) else {
                if Self.isOperatingHours() {
                    print("[Tracking] \(task.doctorName) 看診時間內查無資料，標記結束")
                    tasks[i].status = .finished
                    tasks[i].lastUpdated = Date()
                    saveRecord(task: tasks[i], reason: "finished")
                    notifications.sendFinished(task: tasks[i])
                    removeFinished(taskId: task.id)
                }
                continue
            }

            let newNumber = found.currentNumber
            guard newNumber != task.currentNumber else {
                tasks[i].lastUpdated = Date()
                continue
            }

            print("[Tracking] \(task.doctorName) 叫號更新: \(task.currentNumber) → \(newNumber)")
            tasks[i].currentNumber = newNumber
            tasks[i].lastUpdated = Date()
            // 累積叫號快照（最多保留 10 筆）
            tasks[i].numberHistory.append(NumberSnapshot(number: newNumber, timestamp: Date()))
            if tasks[i].numberHistory.count > 10 { tasks[i].numberHistory.removeFirst() }
            evaluateNotification(taskIndex: i)
        }

        persist()
    }

    private func evaluateNotification(taskIndex i: Int) {
        var task = tasks[i]
        guard task.status == .active else { return }
        guard let userNumber = task.userNumber else { return }

        let cur = task.currentNumber

        if cur > userNumber {
            task.status = .skipped
            task.skippedReminderCount += 1
            tasks[i] = task
            notifications.sendSkipped(task: task, reminderCount: task.skippedReminderCount)
            if task.skippedReminderCount >= 3 { removeFinished(taskId: task.id) }
            return
        }

        if cur == userNumber {
            task.status = .notified
            tasks[i] = task
            saveRecord(task: task, reason: "notified")
            notifications.sendYourTurn(task: task)
            removeFinished(taskId: task.id)
            return
        }

        let remaining = userNumber - cur
        let threshold = task.threshold
        let mode = persistence.notifyMode

        let shouldNotify: Bool
        switch mode {
        case .light:  shouldNotify = [10, 5, 3, 2, 1].contains(remaining) && remaining <= threshold
        case .normal: shouldNotify = remaining <= threshold
        case .final_: shouldNotify = remaining <= 3
        }

        if shouldNotify {
            notifications.sendProgressUpdate(task: task, remaining: remaining)
        }
    }

    private func removeFinished(taskId: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.tasks.removeAll { $0.id == taskId && $0.isFinished }
            self.persist()
        }
    }

    // MARK: - History

    private func saveRecord(task: TrackingTask, reason: String) {
        let record = TrackingRecord(
            id: UUID(),
            hospitalName: task.hospitalName,
            doctorName: task.doctorName,
            clinicRoom: task.clinicRoom,
            date: Date(),
            userNumber: task.userNumber,
            finalNumber: task.currentNumber,
            endReason: reason
        )
        persistence.appendHistory(record)
        print("[Tracking] 歷史紀錄已儲存: \(task.doctorName) reason=\(reason)")
    }

    // MARK: - Timer

    func restartPollingTimer() {
        pollingTimer?.invalidate()
        startPollingTimer()
    }

    func startPollingTimer() {
        let interval = TimeInterval(persistence.refreshInterval)
        pollingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { await self?.refreshAllTasks() }
        }
    }

    // MARK: - Persistence

    private func persist() {
        persistence.trackingTasks = tasks
        WidgetCenter.shared.reloadAllTimelines()
    }

    // 台灣看診時間：週一～六 07:00–21:00（週日不開診）
    static func isOperatingHours() -> Bool {
        let cal = Calendar.current
        let now = Date()
        let hour    = cal.component(.hour,    from: now)
        let weekday = cal.component(.weekday, from: now) // 1 = 週日
        guard weekday != 1 else { return false }
        return hour >= 7 && hour < 21
    }
}

enum TrackingError: LocalizedError {
    case maxTasksReached
    case alreadyTracking

    var errorDescription: String? {
        switch self {
        case .maxTasksReached: return "已達追蹤上限（3 位），請先停止一個追蹤"
        case .alreadyTracking: return "此醫師已在追蹤中"
        }
    }
}

import Foundation
import Combine

@MainActor
final class TrackingService: ObservableObject {
    static let shared = TrackingService()
    private init() {
        tasks = PersistenceService.shared.trackingTasks
            .filter { !$0.isFinished }
        startPollingTimer()
    }

    static let maxTasks = 3

    @Published private(set) var tasks: [TrackingTask] = []

    private var pollingTimer: Timer?
    private let persistence = PersistenceService.shared
    private let notifications = NotificationService.shared

    // MARK: - 新增追蹤

    func startTracking(
        hospital: Hospital,
        progress: ClinicProgress,
        userNumber: Int?,
        threshold: Int
    ) async throws {
        guard tasks.count < Self.maxTasks else {
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

        var task = TrackingTask(
            id: UUID(),
            dbId: nil,
            hospitalCode: hospital.code,
            hospitalName: hospital.name,
            department: progress.department,
            doctorName: progress.doctorName,
            clinicRoom: progress.clinicRoom,
            userNumber: userNumber,
            threshold: threshold,
            currentNumber: progress.currentNumber,
            lastUpdated: Date(),
            status: .active
        )

        tasks.append(task)
        persist()

        // 背景記錄到後端
        Task.detached(priority: .background) { [task] in
            let request = TrackStartRequest(
                guestId: PersistenceService.shared.guestId,
                hospitalCode: task.hospitalCode,
                department: task.department,
                doctorName: task.doctorName,
                clinicRoom: task.clinicRoom,
                session: nil,
                userNumber: task.userNumber ?? 0
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
    }

    // MARK: - 停止追蹤

    func stopTracking(taskId: UUID, reason: String = "cancelled") {
        guard let idx = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        var task = tasks[idx]

        notifications.cancelNotifications(for: taskId)

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

        task.status = .cancelled
        tasks[idx] = task
        tasks.remove(at: idx)
        persist()
    }

    // MARK: - 輪詢

    func refreshAllTasks() async {
        let activeTasks = tasks.filter { $0.status == .active }
        guard !activeTasks.isEmpty else { return }

        let hospitalCodes = Set(activeTasks.map { $0.hospitalCode })

        await withTaskGroup(of: Void.self) { group in
            for code in hospitalCodes {
                group.addTask {
                    await self.poll(hospitalCode: code)
                }
            }
        }
    }

    private func poll(hospitalCode: String) async {
        guard let response = try? await APIClient.shared.get(
            APIEndpoints.progress(hospitalCode: hospitalCode)
        ) as ProgressResponse else { return }

        for i in tasks.indices {
            guard tasks[i].hospitalCode == hospitalCode,
                  tasks[i].status == .active else { continue }

            let task = tasks[i]
            let found = response.data.first {
                $0.doctorName == task.doctorName && $0.clinicRoom == task.clinicRoom
            }

            if found == nil {
                tasks[i].status = .finished
                tasks[i].lastUpdated = Date()
                notifications.sendFinished(task: tasks[i])
                removeFinished(taskId: task.id)
                continue
            }

            let newNumber = found!.currentNumber
            guard newNumber != task.currentNumber else {
                tasks[i].lastUpdated = Date()
                continue
            }

            tasks[i].currentNumber = newNumber
            tasks[i].lastUpdated = Date()

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
            // 過號
            task.status = .skipped
            task.skippedReminderCount += 1
            tasks[i] = task
            notifications.sendSkipped(task: task, reminderCount: task.skippedReminderCount)
            if task.skippedReminderCount >= 3 {
                removeFinished(taskId: task.id)
            }
            return
        }

        if cur == userNumber {
            task.status = .notified
            tasks[i] = task
            notifications.sendYourTurn(task: task)
            removeFinished(taskId: task.id)
            return
        }

        let remaining = userNumber - cur
        let mode = persistence.notifyMode
        let threshold = task.threshold

        let shouldNotify: Bool
        switch mode {
        case .light:
            shouldNotify = [10, 5, 3, 2, 1].contains(remaining) && remaining <= threshold
        case .normal:
            shouldNotify = remaining <= threshold
        case .final_:
            shouldNotify = remaining <= 3
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

    // MARK: - Timer

    private func startPollingTimer() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { await self?.refreshAllTasks() }
        }
    }

    // MARK: - Persistence

    private func persist() {
        persistence.trackingTasks = tasks
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

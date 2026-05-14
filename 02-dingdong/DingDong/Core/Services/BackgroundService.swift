import Foundation
import BackgroundTasks

final class BackgroundService {
    static let shared = BackgroundService()
    private init() {}

    static let taskIdentifier = "com.ajz.dingdong.refresh"

    func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            print("[BG] 背景任務觸發: \(task.identifier)")
            guard let refreshTask = task as? BGAppRefreshTask else {
                print("[BG] 錯誤：task 類型不符，expected BGAppRefreshTask got \(type(of: task))")
                task.setTaskCompleted(success: false)
                return
            }
            self.handleRefresh(task: refreshTask)
        }
    }

    func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("[BG] 下次背景刷新已排程，最早 15 分後")
        } catch {
            print("[BG] 排程失敗: \(error)")
        }
    }

    private func handleRefresh(task: BGAppRefreshTask) {
        print("[BG] 開始背景刷新")
        scheduleNextRefresh()

        let refreshTask = Task {
            await TrackingService.shared.refreshAllTasks()
            print("[BG] 背景刷新完成")
        }

        task.expirationHandler = {
            print("[BG] 背景任務過期，取消中")
            refreshTask.cancel()
        }

        Task {
            await refreshTask.value
            task.setTaskCompleted(success: true)
        }
    }
}

import Foundation
import UserNotifications
import UIKit

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()
    private init() {}

    @Published var isAuthorized = false
    @Published var apnsToken: String?

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            isAuthorized = false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
        if isAuthorized {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    // MARK: - 發通知

    func sendProgressUpdate(task: TrackingTask, remaining: Int) {
        let content = UNMutableNotificationContent()
        content.title = "\(task.doctorName) \(task.clinicRoom)"
        content.body = "還差 \(remaining) 號輪到您"
        content.sound = .default
        schedule(content: content, id: "progress-\(task.id)")
    }

    func sendYourTurn(task: TrackingTask) {
        let content = UNMutableNotificationContent()
        content.title = "叮咚！輪到您了"
        if let userNumber = task.userNumber {
            content.body = "\(task.doctorName) \(task.clinicRoom) 現在叫 \(userNumber) 號，請前往候診"
        } else {
            content.body = "\(task.doctorName) \(task.clinicRoom) 現在叫號 #\(task.currentNumber)"
        }
        content.sound = UNNotificationSound(named: UNNotificationSoundName("dingdong.caf"))
        content.interruptionLevel = .timeSensitive
        schedule(content: content, id: "turn-\(task.id)")
    }

    func sendSkipped(task: TrackingTask, reminderCount: Int) {
        guard let userNumber = task.userNumber else { return }
        let content = UNMutableNotificationContent()
        content.title = "⚠️ 可能過號"
        content.body = "您是 \(userNumber) 號，目前叫 \(task.currentNumber) 號，請洽詢護理站（提醒 \(reminderCount)/3）"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("dingdong.caf"))
        content.interruptionLevel = .timeSensitive
        schedule(content: content, id: "skipped-\(task.id)-\(reminderCount)")
    }

    func sendFinished(task: TrackingTask) {
        let content = UNMutableNotificationContent()
        content.title = "看診已結束"
        content.body = "\(task.doctorName) \(task.clinicRoom) 今日看診已結束"
        content.sound = .default
        schedule(content: content, id: "finished-\(task.id)")
    }

    func cancelNotifications(for taskId: UUID) {
        let identifiers = [
            "progress-\(taskId)",
            "turn-\(taskId)",
            "skipped-\(taskId)-1",
            "skipped-\(taskId)-2",
            "skipped-\(taskId)-3",
            "finished-\(taskId)"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func schedule(content: UNMutableNotificationContent, id: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

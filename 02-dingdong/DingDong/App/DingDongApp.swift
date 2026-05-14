import SwiftUI
import BackgroundTasks
import UserNotifications

@main
struct DingDongApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var trackingService    = TrackingService.shared
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var favoriteService     = FavoriteService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(trackingService)
                .environmentObject(notificationService)
                .environmentObject(favoriteService)
                .background(Color(UIColor.systemBackground).ignoresSafeArea())
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        BackgroundService.shared.registerTasks()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Task { await TrackingService.shared.refreshAllTasks() }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        BackgroundService.shared.scheduleNextRefresh()
    }

    // MARK: - APNs

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        Task { @MainActor in
            NotificationService.shared.apnsToken = token
        }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Expected on Simulator
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let taskId = userInfo["task_id"] as? Int {
            Task { @MainActor in
                NotificationService.shared.pendingDeepLinkTaskId = taskId
            }
        }
        completionHandler()
    }
}

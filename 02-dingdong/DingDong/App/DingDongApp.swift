import SwiftUI
import BackgroundTasks
import UserNotifications

@main
struct DingDongApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var trackingService = TrackingService.shared
    @StateObject private var notificationService = NotificationService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(trackingService)
                .environmentObject(notificationService)
                .background(Color.appBackground.ignoresSafeArea())
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
        Task {
            await TrackingService.shared.refreshAllTasks()
        }
    }

    // 通知在前台也顯示
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // 點通知開啟 App
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}

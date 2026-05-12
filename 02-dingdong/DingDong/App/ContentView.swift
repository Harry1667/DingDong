import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trackingService: TrackingService
    @EnvironmentObject var notificationService: NotificationService
    @State private var showOnboarding = !PersistenceService.shared.onboardingDone

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("追蹤", systemImage: "bell.fill") }

            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape.fill") }
        }
        .tint(Color.appGreen)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                PersistenceService.shared.onboardingDone = true
                showOnboarding = false
            }
            .environmentObject(notificationService)
        }
    }
}

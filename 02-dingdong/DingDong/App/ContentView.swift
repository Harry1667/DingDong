import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trackingService: TrackingService
    @EnvironmentObject var notificationService: NotificationService
    @State private var showOnboarding = !PersistenceService.shared.onboardingDone
    @State private var showSplash = true
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("追蹤", systemImage: "bell.fill") }
                    .tag(0)

                HistoryView()
                    .tabItem { Label("我的紀錄", systemImage: "clock.arrow.circlepath") }
                    .tag(1)

                SettingsView()
                    .tabItem { Label("設定", systemImage: "gearshape.fill") }
                    .tag(2)
            }
            .tint(Color.appGreen)
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView {
                    PersistenceService.shared.onboardingDone = true
                    showOnboarding = false
                }
                .environmentObject(notificationService)
            }
            .onChange(of: notificationService.pendingDeepLinkTaskId) { taskId in
                if taskId != nil { selectedTab = 0 }
            }

            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeOut(duration: 0.45)) {
                    showSplash = false
                }
            }
        }
    }
}

private struct SplashView: View {
    @State private var scale: CGFloat = 0.72
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trackingService: TrackingService

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("追蹤", systemImage: "bell.fill")
                }

            HospitalListView()
                .tabItem {
                    Label("醫院", systemImage: "cross.case.fill")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
        }
        .tint(Color.appGreen)
    }
}

#Preview {
    ContentView()
        .environmentObject(TrackingService.shared)
        .environmentObject(NotificationService.shared)
}

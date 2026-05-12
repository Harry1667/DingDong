import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trackingService: TrackingService

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("追蹤", systemImage: "bell.fill")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
        }
        .tint(Color.appGreen)
    }
}

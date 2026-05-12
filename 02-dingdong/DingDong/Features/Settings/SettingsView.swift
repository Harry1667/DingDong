import SwiftUI

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @EnvironmentObject var notificationService: NotificationService

    var body: some View {
        NavigationStack {
            List {
                Section("通知設定") {
                    Picker("通知頻率", selection: $vm.notifyMode) {
                        ForEach(NotifyMode.allCases, id: \.self) { mode in
                            VStack(alignment: .leading) {
                                Text(mode.displayName)
                            }
                            .tag(mode)
                        }
                    }

                    Stepper(value: $vm.notifyThreshold, in: 1...20) {
                        HStack {
                            Text("提醒閾值")
                            Spacer()
                            Text("差 \(vm.notifyThreshold) 號")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !notificationService.isAuthorized {
                        Button {
                            Task { await notificationService.requestAuthorization() }
                        } label: {
                            Label("開啟通知權限", systemImage: "bell.badge.fill")
                                .foregroundStyle(Color.appGreen)
                        }
                    }
                }

                Section("關於") {
                    LabeledContent("版本", value: Bundle.main.appVersion)
                    LabeledContent("資料來源", value: "dd.dl-app.com")
                    LabeledContent("支援醫院", value: "29 間")
                }

                Section("說明") {
                    Text("叮咚到號會自動追蹤您選擇的醫師看診進度，每 30 秒更新一次。切換至背景後，系統會定期喚醒 App 繼續追蹤。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("設定")
        }
        .task { await notificationService.checkAuthorizationStatus() }
    }
}

private extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }
}

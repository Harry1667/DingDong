import SwiftUI

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @EnvironmentObject var notificationService: NotificationService

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                List {
                    Section("通知") {
                        Stepper(value: $vm.notifyThreshold, in: 1...20) {
                            HStack {
                                Text("提前提醒")
                                    .foregroundStyle(Color.appTextPrimary)
                                Spacer()
                                Text("差 \(vm.notifyThreshold) 號")
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundStyle(Color.appGreen)
                            }
                        }

                        Toggle(isOn: $vm.hapticEnabled) {
                            Text("震動提示")
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .tint(Color.appGreen)

                        if !notificationService.isAuthorized {
                            Button {
                                Task { await notificationService.requestAuthorization() }
                            } label: {
                                Label("開啟通知權限", systemImage: "bell.badge.fill")
                                    .foregroundStyle(Color.appGreen)
                            }
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    Section("更新頻率") {
                        Picker("更新頻率", selection: $vm.refreshInterval) {
                            Text("30 秒").tag(30)
                            Text("1 分鐘").tag(60)
                            Text("2 分鐘").tag(120)
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(Color.appSurface)

                        Text("更新越頻繁越省電越耗電；背景追蹤建議 30 秒")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .listRowBackground(Color.appSurface)

                    Section("關於") {
                        LabeledContent("版本", value: Bundle.main.appVersion)
                            .foregroundStyle(Color.appTextPrimary)
                        LabeledContent("資料來源", value: "dd.dl-app.com")
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    .listRowBackground(Color.appSurface)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
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

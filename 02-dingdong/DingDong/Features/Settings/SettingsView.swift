import SwiftUI

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var trackingService: TrackingService
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                List {
                    // MARK: 通知
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

                    // MARK: 提醒方式
                    Section {
                        Picker("提醒方式", selection: $vm.notifyMode) {
                            ForEach(NotifyMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(Color.appSurface)

                        Group {
                            switch vm.notifyMode {
                            case .light:
                                Text("差 10、5、3、2、1 號時提醒，不打擾")
                            case .normal:
                                Text("進入門檻號數後，每次叫號都通知")
                            case .final_:
                                Text("只在差 3 號以內才提醒")
                            }
                        }
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextSecondary)
                    } header: {
                        Text("提醒方式")
                    }
                    .listRowBackground(Color.appSurface)

                    // MARK: 更新頻率
                    Section("更新頻率") {
                        Picker("更新頻率", selection: $vm.refreshInterval) {
                            Text("30 秒").tag(30)
                            Text("1 分鐘").tag(60)
                            Text("2 分鐘").tag(120)
                        }
                        .pickerStyle(.segmented)
                        .listRowBackground(Color.appSurface)

                        Text("越頻繁越耗電；背景追蹤建議 30 秒")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .listRowBackground(Color.appSurface)

                    // MARK: 資料管理
                    Section("資料管理") {
                        Button(role: .destructive) {
                            showClearConfirm = true
                        } label: {
                            Label("清除所有追蹤任務", systemImage: "trash")
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    // MARK: 其他
                    Section("其他") {
                        Button {
                            if let url = URL(string: "mailto:amacooky.com@gmail.com?subject=叮咚到號意見回饋") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("意見回饋", systemImage: "envelope")
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }
                    .listRowBackground(Color.appSurface)

                    // MARK: 關於
                    Section("關於") {
                        LabeledContent("版本", value: Bundle.main.appVersion)
                            .foregroundStyle(Color.appTextPrimary)
                        LabeledContent("資料來源", value: "dd.dl-app.com")
                            .foregroundStyle(Color.appTextPrimary)
                        NavigationLink(destination: PrivacyPolicyView()) {
                            Text("隱私政策")
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }
                    .listRowBackground(Color.appSurface)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("設定")
            .alert("清除所有追蹤任務", isPresented: $showClearConfirm) {
                Button("確定清除", role: .destructive) {
                    for task in trackingService.tasks {
                        trackingService.stopTracking(taskId: task.id, reason: "manual_clear")
                    }
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("所有進行中的追蹤將被停止，此操作無法復原")
            }
        }
        .task { await notificationService.checkAuthorizationStatus() }
    }
}

private extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }
}

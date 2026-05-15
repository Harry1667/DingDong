import SwiftUI

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var trackingService: TrackingService
    @State private var showClearConfirm = false
    @State private var showPaywall = false
    @State private var tier: UserTier = PersistenceService.shared.userTier

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    ScrollView {
                        VStack(spacing: 14) {
                            subscriptionCard
                            notifyModeCard
                            otherNotifyCard
                            refreshIntervalCard
                            dataManagementCard
                            otherCard
                            aboutCard
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarHidden(true)
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
            .sheet(isPresented: $showPaywall, onDismiss: {
                tier = PersistenceService.shared.userTier
            }) {
                PaywallView()
            }
        }
        .task { await notificationService.checkAuthorizationStatus() }
    }

    // MARK: ── 訂閱卡（最上方）──

    private var subscriptionCard: some View {
        Button { showPaywall = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: tier == .paid
                                    ? [Color.appOk, Color.appOkD2]
                                    : [Color.appAccent, Color.appAccentD],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 50, height: 50)
                    Image(systemName: tier == .paid ? "checkmark.seal.fill" : "sparkles")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(tier == .paid ? "Pro 會員" : "升級為 Pro")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.appInk)
                    Text(tier == .paid
                         ? "同時追 3 位醫生 · 永久看診紀錄"
                         : "一次追 3 位醫生，看診不再錯過")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appInkSoft)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.appInk3)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .simpleCard(radius: 16,
                        borderColor: tier == .paid ? Color.appOk.opacity(0.4) : Color.appAccent.opacity(0.4),
                        borderWidth: 2.5)
        }
        .buttonStyle(.plain)
    }

    private var header: some View {
        VStack(spacing: 4) {
            HStack {
                Spacer()
                Text("叮咚到號")
                    .font(.system(size: 18, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(Color.appInk)
                Spacer()
            }
            .frame(height: 44)
            Text("設定")
                .font(.system(size: 22, weight: .heavy))
                .tracking(-0.3)
                .foregroundStyle(Color.appInk)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    // MARK: ── Cards ─────────────────────────────────────────

    private var notifyModeCard: some View {
        settingCard("通知方式") {
            VStack(spacing: 14) {
                segmentPicker(
                    items: NotifyMode.allCases.map { ($0.displayName, $0) },
                    selection: $vm.notifyMode
                )
                Text(notifyDescription)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appInkSoft)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if vm.notifyMode != .final_ {
                    HStack {
                        Text("提前提醒")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(Color.appInk)
                        Spacer()
                        Stepper(value: $vm.notifyThreshold, in: 1...20) {
                            Text("差 \(vm.notifyThreshold) 號")
                                .font(.system(size: 15, weight: .heavy, design: .monospaced))
                                .foregroundStyle(Color.appAccentD)
                        }
                        .fixedSize()
                    }
                }
            }
        }
    }

    private var notifyDescription: String {
        switch vm.notifyMode {
        case .light:  return "差 10、5、3、2、1 號時提醒，不打擾"
        case .normal: return "進入門檻號數後，每次叫號都通知"
        case .final_: return "只在差 3 號以內才提醒"
        }
    }

    private var otherNotifyCard: some View {
        settingCard("其他提醒") {
            VStack(spacing: 12) {
                HStack {
                    Text("震動提示")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(Color.appInk)
                    Spacer()
                    Toggle("", isOn: $vm.hapticEnabled)
                        .labelsHidden()
                        .tint(Color.appAccent)
                }
                HStack {
                    Text("音效提示")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(Color.appInk)
                    Spacer()
                    Toggle("", isOn: $vm.soundEnabled)
                        .labelsHidden()
                        .tint(Color.appAccent)
                }
                if !notificationService.isAuthorized {
                    Button {
                        Task { await notificationService.requestAuthorization() }
                    } label: {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                            Text("開啟通知權限")
                                .font(.system(size: 15, weight: .heavy))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .heavy))
                        }
                        .foregroundStyle(Color.appAccentD)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var refreshIntervalCard: some View {
        settingCard("更新頻率") {
            VStack(spacing: 10) {
                segmentPicker(
                    items: [("30 秒", 30), ("1 分鐘", 60), ("2 分鐘", 120)],
                    selection: $vm.refreshInterval
                )
                Text("越頻繁越耗電；背景追蹤建議 30 秒")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appInkSoft)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var dataManagementCard: some View {
        settingCard("資料管理") {
            Button(role: .destructive) {
                showClearConfirm = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("清除所有追蹤任務")
                        .font(.system(size: 15, weight: .heavy))
                    Spacer()
                }
                .foregroundStyle(Color.appDangerD)
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
    }

    private var otherCard: some View {
        settingCard("其他") {
            Button {
                if let url = URL(string: "mailto:amacooky.com@gmail.com?subject=叮咚到號意見回饋") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Image(systemName: "envelope")
                    Text("意見回饋")
                        .font(.system(size: 15, weight: .heavy))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .heavy))
                }
                .foregroundStyle(Color.appInk)
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
    }

    private var aboutCard: some View {
        settingCard("關於") {
            VStack(spacing: 12) {
                infoRow(label: "版本", value: Bundle.main.appVersion)
                infoRow(label: "資料來源", value: "dd.dl-app.com")
                NavigationLink(destination: PrivacyPolicyView()) {
                    HStack {
                        Text("隱私政策")
                            .font(.system(size: 15, weight: .heavy))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .heavy))
                    }
                    .foregroundStyle(Color.appInk)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: ── Helpers ──────────────────────────────────────

    private func settingCard<Content: View>(_ title: String,
                                            @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .heavy))
                .tracking(2)
                .foregroundStyle(Color.appInkSoft)
                .padding(.horizontal, 2)
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .padding(16)
            .simpleCard(radius: 16)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(Color.appInk)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.appInkSoft)
        }
        .padding(.vertical, 4)
    }

    private func segmentPicker<T: Hashable>(items: [(String, T)],
                                            selection: Binding<T>) -> some View {
        HStack(spacing: 6) {
            ForEach(items, id: \.1) { (title, value) in
                Button {
                    selection.wrappedValue = value
                } label: {
                    Text(title)
                        .font(.system(size: 14, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(selection.wrappedValue == value ? .white : Color.appInk)
                        .background(selection.wrappedValue == value ? Color.appAccent : Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selection.wrappedValue == value ? Color.appAccent : Color.appBorder, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }
}

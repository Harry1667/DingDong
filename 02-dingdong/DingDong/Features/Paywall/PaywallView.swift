import SwiftUI

/// 訂閱頁。對齊網頁 /simple 的「升級 Pro 追 3 個」入口。
/// 目前為測試模式：按下「升級為 Pro」直接把 dd_tier 設為 paid（未來接 StoreKit）。
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPaid: Bool = PersistenceService.shared.userTier == .paid
    @State private var selectedPlan: Plan = .yearly
    @State private var showRestoreAlert = false

    enum Plan: String, CaseIterable, Identifiable {
        case monthly, yearly
        var id: String { rawValue }
        var title: String {
            switch self {
            case .monthly: return "每月"
            case .yearly:  return "每年"
            }
        }
        var price: String {
            switch self {
            case .monthly: return "NT$30"
            case .yearly:  return "NT$300"
            }
        }
        var pricePerMonth: String {
            switch self {
            case .monthly: return "30 / 月"
            case .yearly:  return "25 / 月"
            }
        }
        var badge: String? {
            switch self {
            case .monthly: return nil
            case .yearly:  return "省 17%"
            }
        }
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    benefitsList
                    if isPaid {
                        paidStatusCard
                    } else {
                        plansRow
                        ctaButton
                    }
                    footerLinks
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            closeBar
        }
        .alert("恢復購買", isPresented: $showRestoreAlert) {
            Button("確定", role: .cancel) {}
        } message: {
            Text("尚未串接 App Store 訂閱。\n正式版上線後，這裡會自動還原您的購買紀錄。")
        }
    }

    // MARK: - Close bar

    private var closeBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .heavy))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(Color.appInk)
                    .background(Color.appCard)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.appBorder, lineWidth: 2))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(Color.appBg)
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 26)
                    .fill(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appAccentD],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: Color.appAccentDD.opacity(0.5), radius: 0, x: 0, y: 5)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .padding(.top, 8)

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Text("叮咚到號")
                        .font(.system(size: 26, weight: .heavy))
                        .tracking(-0.5)
                        .foregroundStyle(Color.appInk)
                    Text("Pro")
                        .font(.system(size: 16, weight: .heavy))
                        .tracking(2)
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .foregroundStyle(.white)
                        .background(Color.appAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Text("一次追 3 位醫生，看診不再錯過")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appInkSoft)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Benefits

    private struct Benefit {
        let icon: String
        let title: String
        let body: String
    }

    private let benefits: [Benefit] = [
        Benefit(icon: "person.3.fill",
                title: "同時追蹤 3 位醫生",
                body: "免費版僅 1 位 · Pro 可追全家人的看診"),
        Benefit(icon: "bell.fill",
                title: "優先到號通知",
                body: "差 10 / 5 / 3 / 2 / 1 號層層提醒，不再過號"),
        Benefit(icon: "rectangle.stack.fill",
                title: "完整看診紀錄",
                body: "永久保留所有就診歷史，方便長輩家屬查閱"),
        Benefit(icon: "heart.fill",
                title: "支持開發團隊",
                body: "無廣告、無資料追蹤，您的訂閱讓我們持續服務"),
    ]

    private var benefitsList: some View {
        VStack(spacing: 10) {
            ForEach(0..<benefits.count, id: \.self) { i in
                let b = benefits[i]
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: b.icon)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.appAccent)
                        .frame(width: 42, height: 42)
                        .background(Color.appAccentS)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appAccent.opacity(0.35), lineWidth: 1.5)
                        )
                    VStack(alignment: .leading, spacing: 3) {
                        Text(b.title)
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundStyle(Color.appInk)
                        Text(b.body)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.appInkSoft)
                            .lineSpacing(2)
                    }
                    Spacer(minLength: 0)
                }
                .padding(14)
                .simpleCard(radius: 16)
            }
        }
    }

    // MARK: - Plans

    private var plansRow: some View {
        HStack(spacing: 10) {
            ForEach(Plan.allCases) { plan in
                planCard(plan)
            }
        }
    }

    @ViewBuilder
    private func planCard(_ plan: Plan) -> some View {
        let selected = plan == selectedPlan
        Button {
            withAnimation(.easeInOut(duration: 0.18)) { selectedPlan = plan }
        } label: {
            VStack(spacing: 8) {
                if let badge = plan.badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(1)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .foregroundStyle(.white)
                        .background(Color.appAccent)
                        .clipShape(Capsule())
                } else {
                    Spacer().frame(height: 21)
                }
                Text(plan.title)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.appInkSoft)
                Text(plan.price)
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(-0.5)
                    .foregroundStyle(Color.appInk)
                Text(plan.pricePerMonth)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.appInk2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(selected ? Color.appAccentS : Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(selected ? Color.appAccent : Color.appBorder,
                            lineWidth: selected ? 2.5 : 2)
            )
            .shadow(color: selected ? Color.appAccent.opacity(0.18) : .clear,
                    radius: 0, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA

    private var ctaButton: some View {
        VStack(spacing: 10) {
            Button {
                PersistenceService.shared.userTier = .paid
                withAnimation { isPaid = true }
                SoundService.shared.send()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .heavy))
                    Text("升級為 Pro")
                        .font(.system(size: 20, weight: .heavy))
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(
                        colors: [Color.appAccent, Color.appAccentD],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color.appAccentDD.opacity(0.9), radius: 0, x: 0, y: 5)
            }
            .buttonStyle(.plain)

            Text("測試模式：暫不收費，按下立即生效")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appInk2)
        }
    }

    // MARK: - Paid status

    private var paidStatusCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(Color.appOk)
                VStack(alignment: .leading, spacing: 2) {
                    Text("您已是 Pro 會員")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.appInk)
                    Text("可同時追蹤 3 位醫生")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appInkSoft)
                }
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appOkS)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appOk.opacity(0.4), lineWidth: 2)
            )

            Button {
                PersistenceService.shared.userTier = .free
                withAnimation { isPaid = false }
            } label: {
                Text("降回免費版（測試）")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.appInk2)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color.appCard)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.appBorder, lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Footer links

    private var footerLinks: some View {
        VStack(spacing: 10) {
            HStack(spacing: 18) {
                Button("恢復購買") { showRestoreAlert = true }
                Text("·")
                Button("使用條款") {}
                Text("·")
                Button("隱私政策") {}
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color.appInk2)

            Text("訂閱會在每期到期時自動續訂，可於 App Store 設定中取消。")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.appInk3)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 8)
        }
    }
}

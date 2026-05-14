import SwiftUI
import UIKit

/// 追蹤卡（左：醫院/科別/醫師；右：橘框大號碼）
/// 對應 /simple 的 .lt-card 設計，有四種狀態色：active / loading / expired / passed / yours
struct TrackingCardView: View {
    let task: TrackingTask
    let onStop: () -> Void
    var isHighlighted: Bool = false

    @EnvironmentObject private var favoriteService: FavoriteService

    private var rightState: RightState {
        // 未開診 / 超過 4 小時 → expired
        if !TrackingService.isOperatingHours() { return .loading }
        if let userNumber = task.userNumber {
            if task.currentNumber > userNumber { return .passed }
            if task.currentNumber == userNumber { return .yours }
            return .active
        }
        return .loading
    }

    private var isFav: Bool {
        favoriteService.isFavorite(hospitalCode: task.hospitalCode,
                                    doctorName: task.doctorName,
                                    clinicRoom: task.clinicRoom)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            leftBlock
            rightBlock
        }
        .padding(14)
        .simpleCard(
            radius: 18,
            background: cardBackground,
            borderColor: cardBorder,
            borderWidth: 2.5,
            shadowDepth: 2
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.appOk, lineWidth: isHighlighted ? 2 : 0)
                .opacity(isHighlighted ? 1 : 0)
                .animation(.easeInOut(duration: 0.35), value: isHighlighted)
        )
        .contextMenu {
            Button {
                favoriteService.toggle(
                    hospitalCode: task.hospitalCode, hospitalName: task.hospitalName,
                    department: task.department, doctorName: task.doctorName,
                    clinicRoom: task.clinicRoom
                )
            } label: {
                Label(isFav ? "移除常用" : "加入常用",
                      systemImage: isFav ? "star.slash" : "star")
            }
            Button(role: .destructive, action: onStop) {
                Label("停止追蹤", systemImage: "bell.slash.fill")
            }
        }
        .onChange(of: task.currentNumber) { _ in
            haptic(.light)
        }
        .onChange(of: rightState) { state in
            if state == .yours || state == .passed { haptic(.warning) }
        }
    }

    // MARK: ── Left ──────────────────────────────────────────

    private var leftBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                SimpleLiveDot(color: rightState == .passed ? .appDanger : .appOk)
                Text(rightState == .loading ? "上次追蹤" : "⟳ 目前追蹤")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(rightState == .loading ? Color.appInk3 : Color.appOk)
            }
            Text(task.hospitalName)
                .font(.system(size: 20, weight: .heavy))
                .tracking(-0.3)
                .foregroundStyle(Color.appInk)
                .lineLimit(1)
            Text(detailLine)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appInkSoft)
                .lineLimit(2)
                .padding(.top, 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var detailLine: String {
        var parts: [String] = []
        if !task.department.isEmpty { parts.append(task.department) }
        if !task.doctorName.isEmpty { parts.append(task.doctorName) }
        if !task.clinicRoom.isEmpty { parts.append(task.clinicRoom) }
        return parts.joined(separator: " · ")
    }

    // MARK: ── Right ─────────────────────────────────────────

    private var rightBlock: some View {
        VStack(spacing: 3) {
            Text(rightTopLabel)
                .font(.system(size: 12, weight: .heavy))
                .tracking(0.5)
                .foregroundStyle(rightDarkColor)
            Text(rightTopValue)
                .font(.system(size: 34, weight: .heavy))
                .tracking(-1.5)
                .foregroundStyle(rightColor)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.spring(response: 0.4, dampingFraction: 0.75),
                           value: rightTopValue)
            Text("號")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(rightDarkColor)
            if let userNumber = task.userNumber, rightState != .loading {
                divider
                    .padding(.vertical, 4)
                HStack(spacing: 4) {
                    Text("您是")
                        .font(.system(size: 12, weight: .bold))
                    Text("\(userNumber)")
                        .font(.system(size: 16, weight: .heavy))
                    Text("號")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(rightDarkColor)
            }
            Text(rightBottomText)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(rightDarkColor)
                .padding(.top, 2)
        }
        .frame(minWidth: 116)
        .padding(.vertical, 8).padding(.horizontal, 10)
        .background(rightBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(rightColor, lineWidth: 2)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(rightDarkColor.opacity(0.25))
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 2)
    }

    // MARK: ── 狀態與配色 ──────────────────────────────────────

    private enum RightState: Equatable { case active, yours, passed, loading }

    private var rightColor: Color {
        switch rightState {
        case .active:  return Color.appAccent
        case .yours:   return Color(hex: "#04A256")
        case .passed:  return Color.appDanger
        case .loading: return Color.appInk2
        }
    }
    private var rightDarkColor: Color {
        switch rightState {
        case .active:  return Color.appAccentD
        case .yours:   return Color.appOkD2
        case .passed:  return Color.appDangerD
        case .loading: return Color.appInk3
        }
    }
    private var rightBackground: Color {
        switch rightState {
        case .active:  return Color.appAccentS
        case .yours:   return Color.appOkS
        case .passed:  return Color.appDangerS
        case .loading: return Color.appClosed
        }
    }
    private var cardBackground: Color {
        rightState == .loading ? Color.appCard : Color(hex: "#F0F7F3")
    }
    private var cardBorder: Color {
        rightState == .loading ? Color.appBorder : Color.appOk
    }
    private var rightTopLabel: String {
        rightState == .loading ? "您的號碼" : "目前看到"
    }
    private var rightTopValue: String {
        if rightState == .loading {
            return task.userNumber.map(String.init) ?? "—"
        }
        return "\(task.currentNumber)"
    }
    private var rightBottomText: String {
        switch rightState {
        case .passed:  return "已過號"
        case .yours:   return "輪到您"
        case .active:
            if let userNumber = task.userNumber {
                let rem = userNumber - task.currentNumber
                return "還差 \(rem) 號"
            }
            return "追蹤中…"
        case .loading: return "追蹤中…"
        }
    }

    // MARK: ── Haptic ────────────────────────────────────────

    private func haptic(_ style: HapticStyle) {
        guard PersistenceService.shared.hapticEnabled else { return }
        switch style {
        case .light:   UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .warning: UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }

    private enum HapticStyle { case light, warning }
}

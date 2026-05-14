import SwiftUI
import UIKit

struct TrackingCardView: View {
    let task: TrackingTask
    let onStop: () -> Void
    var isHighlighted: Bool = false

    @EnvironmentObject private var favoriteService: FavoriteService
    @State private var pulseOpacity: Double = 1.0

    private var isFav: Bool {
        favoriteService.isFavorite(hospitalCode: task.hospitalCode,
                                    doctorName: task.doctorName,
                                    clinicRoom: task.clinicRoom)
    }
    private var isUrgent: Bool {
        guard let remaining = task.remaining else { return false }
        return remaining <= 3
    }
    private var accent: Color { isUrgent ? .appUrgency : .appGreen }

    var body: some View {
        VStack(spacing: 0) {
            cardHeader
            Divider().padding(.horizontal, 18)
            numberBlock
            bottomBar
        }
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    isHighlighted  ? Color.appGreen.opacity(0.65) :
                    isUrgent       ? Color.appUrgency.opacity(0.40) :
                                     Color.appBorder,
                    lineWidth: isHighlighted || isUrgent ? 2 : 1
                )
                .animation(.easeInOut(duration: 0.35), value: isHighlighted)
                .animation(.easeInOut(duration: 0.35), value: isUrgent)
        )
        .shadow(
            color: isUrgent
                ? Color.appUrgency.opacity(0.15)
                : Color(red: 0.18, green: 0.42, blue: 0.31).opacity(0.10),
            radius: isUrgent ? 22 : 18, x: 0, y: 6
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
        .onAppear { pulseOpacity = 0.25 }
        .onChange(of: task.currentNumber) { _ in haptic(.light) }
        .onChange(of: isUrgent) { urgent in if urgent { haptic(.warning) } }
    }

    // MARK: ── Header ──────────────────────────────────────────

    private var cardHeader: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text(task.doctorName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                Text("\(task.hospitalName)  ·  \(task.clinicRoom)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            statusPill

            Button {
                favoriteService.toggle(
                    hospitalCode: task.hospitalCode, hospitalName: task.hospitalName,
                    department: task.department, doctorName: task.doctorName,
                    clinicRoom: task.clinicRoom
                )
            } label: {
                Image(systemName: isFav ? "star.fill" : "star")
                    .font(.system(size: 15))
                    .foregroundStyle(isFav ? Color.appGreen : Color.appTextSecondary.opacity(0.35))
                    .frame(width: 24, height: 24)
            }

            Button(action: onStop) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.28))
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 14)
    }

    private var statusPill: some View {
        Group {
            if !TrackingService.isOperatingHours() {
                Label("休診", systemImage: "moon.zzz.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.appTextSecondary.opacity(0.09))
                    .clipShape(Capsule())
            } else {
                HStack(spacing: 4) {
                    Circle()
                        .fill(accent)
                        .frame(width: 6, height: 6)
                        .opacity(pulseOpacity)
                        .animation(
                            .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                            value: pulseOpacity
                        )
                    Text(isUrgent ? "快到了！" : "看診中")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(accent)
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(accent.opacity(0.10))
                .clipShape(Capsule())
            }
        }
    }

    // MARK: ── Number block ────────────────────────────────────

    private var numberBlock: some View {
        VStack(spacing: 10) {
            Text("目前叫號")
                .font(.system(size: 11, weight: .semibold))
                .tracking(3.5)
                .foregroundStyle(isUrgent ? accent.opacity(0.85) : Color.appTextSecondary.opacity(0.55))

            Text("\(task.currentNumber)")
                .font(.system(size: 84, weight: .bold, design: .serif))
                .foregroundStyle(isUrgent ? accent : Color.appTextPrimary)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: task.currentNumber)
                .padding(.top, -4)
                .padding(.bottom, 2)

            VStack(spacing: 5) {
                if let remaining = task.remaining {
                    Text(remainingText(remaining))
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(isUrgent ? accent : Color.appTextSecondary)
                        .animation(.easeInOut(duration: 0.3), value: remaining)
                }
                if let mins = task.estimatedMinutes {
                    Text("預估還需 \(mins) 分鐘")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.55))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.top, 26)
        .padding(.bottom, 24)
    }

    // MARK: ── Bottom bar ──────────────────────────────────────

    private var bottomBar: some View {
        VStack(spacing: 0) {
            if let userNumber = task.userNumber, userNumber > 0, task.remaining != nil {
                let progress = min(Double(task.currentNumber) / Double(userNumber), 1.0)

                HStack {
                    Text("更新 " + task.lastUpdated.relativeString)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.45))
                    Spacer()
                    Text("掛號 #\(userNumber)")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.45))
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 10)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.appBorder.opacity(0.6))
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [accent.opacity(0.7), accent],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * progress)
                            .animation(.spring(response: 0.6, dampingFraction: 0.85), value: progress)
                    }
                }
                .frame(height: 6)
            } else {
                Text("更新 " + task.lastUpdated.relativeString)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 14)
            }
        }
    }

    // MARK: ── Haptic ──────────────────────────────────────────

    private func haptic(_ style: HapticStyle) {
        guard PersistenceService.shared.hapticEnabled else { return }
        switch style {
        case .light:   UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .warning: UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }

    private enum HapticStyle { case light, warning }

    private func remainingText(_ remaining: Int) -> String {
        if remaining <= 0 { return "輪到您了！請準備就緒" }
        if remaining == 1 { return "差 1 號，請準備好了" }
        return "還差 \(remaining) 號輪到您"
    }
}

import SwiftUI
import UIKit

struct TrackingCardView: View {
    let task: TrackingTask
    let onStop: () -> Void

    private var isUrgent: Bool {
        guard let remaining = task.remaining else { return false }
        return remaining <= 3
    }

    private var numberColor: Color {
        isUrgent ? .appUrgency : .appTextPrimary
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Hero number ──
            VStack(spacing: 4) {
                Text("目前叫號")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.2)
                    .foregroundStyle(isUrgent ? Color.appUrgency : Color.appTextSecondary)

                Text("\(task.currentNumber)")
                    .font(.system(size: 80, weight: .bold, design: .serif))
                    .foregroundStyle(numberColor)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: task.currentNumber)

                if let remaining = task.remaining {
                    Text(remainingText(remaining))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(isUrgent ? Color.appUrgency : Color.appTextSecondary)
                        .animation(.easeInOut(duration: 0.5), value: remaining)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)

            Divider()
                .background(Color.appBorder)
                .padding(.horizontal, 16)

            // ── Doctor info ──
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(task.doctorName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("\(task.hospitalName) · \(task.clinicRoom)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary)
                    Text(task.lastUpdated.relativeString)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.7))
                }

                Spacer()

                if !TrackingService.isOperatingHours() {
                    Text("休診中")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.appTextSecondary.opacity(0.10))
                        .foregroundStyle(Color.appTextSecondary)
                        .clipShape(Capsule())
                } else {
                    Circle()
                        .fill(isUrgent ? Color.appUrgency : Color.appGreenMid)
                        .frame(width: 8, height: 8)
                        .opacity(pulseOpacity)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                                   value: pulseOpacity)
                }

                Button(action: onStop) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.appTextSecondary.opacity(0.5))
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // ── Progress bar ──
            if let _ = task.remaining, let userNumber = task.userNumber, userNumber > 0 {
                let progress = Double(task.currentNumber) / Double(userNumber)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.appBorder)
                        Rectangle()
                            .fill(isUrgent ? Color.appUrgency : Color.appGreenMid)
                            .frame(width: geo.size.width * min(progress, 1.0))
                            .animation(.easeInOut(duration: 0.5), value: progress)
                    }
                }
                .frame(height: 3)
                .clipShape(Rectangle())
            }
        }
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(red: 0.545, green: 0.431, blue: 0.314).opacity(0.10),
                radius: 14, x: 0, y: 3)
        .contextMenu {
            Button(role: .destructive, action: onStop) {
                Label("停止追蹤", systemImage: "bell.slash.fill")
            }
        }
        .onAppear { pulseOpacity = 0.5 }
        .onChange(of: task.currentNumber) { _ in haptic(.light) }
        .onChange(of: isUrgent) { urgent in
            if urgent { haptic(.warning) }
        }
    }

    @State private var pulseOpacity: Double = 1.0

    private func haptic(_ style: HapticStyle) {
        guard PersistenceService.shared.hapticEnabled else { return }
        switch style {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }

    private enum HapticStyle { case light, warning }

    private func remainingText(_ remaining: Int) -> String {
        if remaining <= 0 { return "輪到您了！" }
        if remaining == 1 { return "差 1 號，準備好了嗎" }
        return "差 \(remaining) 號 · #\(task.userNumber ?? 0)"
    }
}

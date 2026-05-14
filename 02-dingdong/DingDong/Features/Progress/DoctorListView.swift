import SwiftUI

struct DoctorListView: View {
    let hospital: Hospital
    let department: String
    @ObservedObject var progressVM: ProgressViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDoctor: ClinicProgress?
    @State private var secondsUntilRefresh: Int = 30
    @State private var refreshTimer: Timer?
    @State private var skipToEnterTrigger: Bool = false

    private var doctors: [ClinicProgress] {
        progressVM.doctors(for: department)
    }

    var body: some View {
        SimpleScreen {
            SimpleTopBar(title: hospital.name, onBack: { dismiss() })
            SimpleStepTitle(
                title: "您找哪位醫生？",
                step: 3, total: 4,
                stepSuffix: department
            )
        } content: {
            content
        }
        .sheet(item: $selectedDoctor) { doctor in
            TrackingSetupView(hospital: hospital, progress: doctor)
        }
        .onAppear { startRefreshCountdown() }
        .onDisappear { stopRefreshCountdown() }
        .refreshable { await progressVM.refresh() }
    }

    @ViewBuilder
    private var content: some View {
        if doctors.isEmpty {
            closedState
        } else {
            SimpleTwoColGrid {
                ForEach(doctors) { doctor in
                    Button {
                        selectedDoctor = doctor
                    } label: {
                        doctorCard(doctor)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 6)
        }
    }

    private func doctorCard(_ doctor: ClinicProgress) -> some View {
        let hasNumber = doctor.currentNumber > 0
        return SimpleGridCard(
            title: doctor.doctorName.isEmpty ? "（未顯示醫師）" : doctor.doctorName,
            subtitle: doctor.clinicRoom,
            isClosed: false,
            trailingMark: nil,
            nowNumber: hasNumber ? doctor.currentNumber : nil,
            nowEmptyText: hasNumber ? nil : "尚未開始叫號",
            minHeight: 150,
            action: {}
        )
        .allowsHitTesting(false)
    }

    // MARK: - Closed / waiting state

    private var closedState: some View {
        VStack(spacing: 16) {
            Text("⏳").font(.system(size: 56))
            Text("目前休診中")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(Color.appInk)
            VStack(spacing: 4) {
                Text(hospital.name)
                Text(department)
                Text("")
                Text("診間尚未開始叫號")
                Text("可能是尚未開診或剛結束")
            }
            .font(.system(size: 15))
            .foregroundStyle(Color.appInkSoft)
            .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.appAccent)
                        .frame(width: 8, height: 8)
                        .opacity(0.4)
                        .scaleEffect(0.9)
                        .pulseDelay(Double(i) * 0.2)
                }
            }
            .padding(.top, 4)

            Text("下次自動更新：\(secondsUntilRefresh) 秒後")
                .font(.system(size: 13))
                .foregroundStyle(Color.appInk2)
                .padding(.top, 4)

            VStack(spacing: 10) {
                SimpleSecondaryButton(title: "立即重試", icon: "arrow.clockwise") {
                    Task { await progressVM.refresh() }
                }
                SimpleSecondaryButton(title: "我知道我的號碼，直接輸入") {
                    let placeholder = ClinicProgress(
                        department: department,
                        doctorName: "",
                        clinicRoom: "",
                        currentNumber: 0,
                        nextNumber: 0,
                        isCurrentSkipped: false,
                        isNextSkipped: false
                    )
                    selectedDoctor = placeholder
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 12)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .center)
        .simpleCard(radius: 20, background: Color.appCardWarm,
                    borderColor: Color(hex: "#F0E4BE"), borderWidth: 2.5, shadowDepth: 0)
        .padding(.top, 16)
    }

    private func startRefreshCountdown() {
        secondsUntilRefresh = 30
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                if secondsUntilRefresh > 1 {
                    secondsUntilRefresh -= 1
                } else {
                    secondsUntilRefresh = 30
                }
            }
        }
    }

    private func stopRefreshCountdown() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}

// MARK: - Helper: 三個小圓點動畫延遲

private struct PulseDelayModifier: ViewModifier {
    let delay: Double
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0.3

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    scale = 1.2
                    opacity = 1.0
                }
            }
    }
}

private extension View {
    func pulseDelay(_ delay: Double) -> some View {
        modifier(PulseDelayModifier(delay: delay))
    }
}

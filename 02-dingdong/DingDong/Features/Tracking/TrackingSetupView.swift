import SwiftUI

struct TrackingSetupView: View {
    @StateObject private var vm: TrackingViewModel
    @Environment(\.dismiss) private var dismiss

    init(hospital: Hospital, progress: ClinicProgress) {
        _vm = StateObject(wrappedValue: TrackingViewModel(hospital: hospital, progress: progress))
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                infoCard
                displayBox
                keypad
            }
        }
        .onChange(of: vm.didStartTracking) { started in
            if started { dismiss() }
        }
        .alert("錯誤", isPresented: .constant(vm.errorMessage != nil)) {
            Button("確定") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: ── Top bar ────────────────────────────────────────

    private var topBar: some View {
        VStack(spacing: 6) {
            HStack {
                SimpleBackButton(action: { dismiss() })
                Spacer()
                Text("叮咚到號")
                    .font(.system(size: 18, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(Color.appInk)
            }
            .frame(height: 44)
            Text("請輸入您的候診號碼")
                .font(.system(size: 22, weight: .heavy))
                .tracking(-0.3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(Color.appBg)
    }

    // MARK: ── Info card ─────────────────────────────────────

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(vm.hospital.name)
                    .font(.system(size: 22, weight: .heavy))
                    .tracking(-0.3)
                    .foregroundStyle(Color.appInk)
                    .lineLimit(1)
                Text(vm.progress.department)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.appInkSoft)
                    .padding(.top, 1)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    if !vm.progress.doctorName.isEmpty {
                        Text(vm.progress.doctorName)
                            .font(.system(size: 19, weight: .heavy))
                            .foregroundStyle(Color.appInk)
                    }
                    if !vm.progress.clinicRoom.isEmpty {
                        Text(vm.progress.clinicRoom)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.appInkSoft)
                    }
                }
                .padding(.top, 3)
                .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if vm.progress.currentNumber > 0 {
                VStack(spacing: 2) {
                    Text("目前看到")
                        .font(.system(size: 12, weight: .heavy))
                        .tracking(0.5)
                        .foregroundStyle(Color.appAccentD)
                    Text("\(vm.progress.currentNumber)")
                        .font(.system(size: 38, weight: .heavy))
                        .tracking(-1.5)
                        .foregroundStyle(Color.appAccent)
                        .monospacedDigit()
                    Text("號")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Color.appAccentD)
                }
                .frame(minWidth: 100)
                .padding(.vertical, 6).padding(.horizontal, 10)
                .background(Color.appAccentS)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.appAccent, lineWidth: 2)
                )
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .simpleCard(radius: 18)
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    // MARK: ── Display box ───────────────────────────────────

    private var displayBox: some View {
        Group {
            if vm.userNumberText.isEmpty {
                Text("請點下方數字")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: "#BFB7A2"))
            } else {
                Text(vm.userNumberText)
                    .font(.system(size: 40, weight: .heavy))
                    .tracking(6)
                    .foregroundStyle(Color.appAccent)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.appInk, lineWidth: 2.5)
        )
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    // MARK: ── Keypad ────────────────────────────────────────

    private var keypad: some View {
        let cols = [
            GridItem(.flexible(), spacing: 6),
            GridItem(.flexible(), spacing: 6),
            GridItem(.flexible(), spacing: 6)
        ]
        return LazyVGrid(columns: cols, spacing: 6) {
            ForEach(1...9, id: \.self) { n in
                keypadButton(label: "\(n)", style: .normal) { input("\(n)") }
            }
            keypadButton(label: "← 刪除", style: .delete) { delete() }
            keypadButton(label: "0", style: .normal) { input("0") }
            keypadButton(
                label: vm.isLoading ? "…" : "確定",
                style: .ok,
                disabled: vm.userNumberText.isEmpty || vm.isLoading
            ) {
                SoundService.shared.send()
                Task { await vm.startTracking() }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private func keypadButton(label: String,
                              style: KeyStyle,
                              disabled: Bool = false,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: style == .normal ? 30 : 18, weight: .heavy))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(disabled ? Color(hex: "#F5EEDC") : style.foreground)
                .background(disabled ? Color.appDisabled : style.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(disabled ? Color.appDisabled : style.borderColor, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: (disabled ? Color(hex: "#B0A78F") : style.shadowColor),
                        radius: 0, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .frame(minHeight: 64)
    }

    private enum KeyStyle {
        case normal, delete, ok

        var foreground: Color {
            switch self {
            case .normal: return .appInk
            case .delete: return .appDanger
            case .ok:     return .white
            }
        }
        var background: Color {
            switch self {
            case .normal: return .appCard
            case .delete: return Color(hex: "#FFF0F0")
            case .ok:     return .appAccent
            }
        }
        var borderColor: Color {
            switch self {
            case .normal: return .appBorder
            case .delete: return Color(hex: "#F5C2C2")
            case .ok:     return .appAccent
            }
        }
        var shadowColor: Color {
            switch self {
            case .normal: return .appBorder
            case .delete: return Color(hex: "#F5C2C2")
            case .ok:     return .appAccentD
            }
        }
    }

    // MARK: ── Input handlers ────────────────────────────────

    private func input(_ d: String) {
        guard vm.userNumberText.count < 4 else { return }
        vm.userNumberText += d
    }

    private func delete() {
        guard !vm.userNumberText.isEmpty else { return }
        vm.userNumberText.removeLast()
    }
}

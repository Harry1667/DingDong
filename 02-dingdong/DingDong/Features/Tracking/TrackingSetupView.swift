import SwiftUI

struct TrackingSetupView: View {
    @StateObject private var vm: TrackingViewModel
    @Environment(\.dismiss) private var dismiss

    init(hospital: Hospital, progress: ClinicProgress) {
        _vm = StateObject(wrappedValue: TrackingViewModel(hospital: hospital, progress: progress))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        doctorInfoCard
                        numberInputSection
                        thresholdSection
                        startButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .navigationTitle("設定追蹤")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("取消") { dismiss() }
                            .foregroundStyle(Color.appGreen)
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
        }
    }

    private var doctorInfoCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.progress.doctorName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("\(vm.hospital.name) · \(vm.progress.department) · \(vm.progress.clinicRoom)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("目前叫號")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary)
                    Text("\(vm.progress.currentNumber)")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundStyle(Color.appGreen)
                }
            }
            .padding(16)
        }
        .cardStyle()
    }

    private var numberInputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("您的掛號號碼")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: 8) {
                TextField("輸入號碼（選填）", text: $vm.userNumberText)
                    .keyboardType(.numberPad)
                    .font(.system(size: 22, weight: .medium, design: .serif))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.appSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appBorder, lineWidth: 1.5)
                    )

                if !vm.userNumberText.isEmpty {
                    Button { vm.userNumberText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appTextSecondary.opacity(0.5))
                            .font(.system(size: 20))
                    }
                }
            }

            if let remaining = vm.remaining {
                HStack(spacing: 6) {
                    Image(systemName: remaining <= 0 ? "bell.fill" : "person.fill.questionmark")
                        .font(.system(size: 12))
                    if remaining > 0 {
                        Text("您是 \(vm.userNumber!) 號，前面還有 \(remaining) 位")
                    } else if remaining == 0 {
                        Text("輪到您了！")
                    } else {
                        Text("您是 \(vm.userNumber!) 號，已超過目前叫號")
                    }
                }
                .font(.system(size: 13))
                .foregroundStyle(remaining <= 0 ? Color.appGreen : Color.appTextSecondary)
            } else {
                Text("不填寫則僅追蹤進度，不設個人提醒")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }

    private var thresholdSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("提醒時機")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)

            Picker("提醒時機", selection: $vm.threshold) {
                Text("差 10 號").tag(10)
                Text("差 5 號").tag(5)
                Text("差 3 號").tag(3)
                Text("輪到才提醒").tag(1)
            }
            .pickerStyle(.segmented)
            .tint(Color.appGreen)

            Text("距離叫到您的號碼多近時發送通知")
                .font(.system(size: 12))
                .foregroundStyle(Color.appTextSecondary)
        }
    }

    private var startButton: some View {
        Button {
            Task { await vm.startTracking() }
        } label: {
            Group {
                if vm.isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.badge.fill")
                        Text("開始追蹤")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.appGreen)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .disabled(vm.isLoading)
        .padding(.top, 4)
    }
}

#Preview {
    TrackingSetupView(
        hospital: Hospital(code: "NTU", name: "台大醫院", shortName: "台大",
                           city: "台北市", district: "中正區", level: "醫學中心", isActive: true),
        progress: ClinicProgress(department: "內科", doctorName: "王小明", clinicRoom: "診間 03",
                                 currentNumber: 42, nextNumber: 43,
                                 isCurrentSkipped: false, isNextSkipped: false)
    )
}

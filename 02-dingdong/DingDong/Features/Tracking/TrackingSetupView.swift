import SwiftUI

struct TrackingSetupView: View {
    @StateObject private var vm: TrackingViewModel
    @Environment(\.dismiss) private var dismiss

    init(hospital: Hospital, progress: ClinicProgress) {
        _vm = StateObject(wrappedValue: TrackingViewModel(hospital: hospital, progress: progress))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    doctorInfoCard
                    numberInputSection
                    thresholdSection
                    startButton
                }
                .padding()
            }
            .navigationTitle("設定追蹤")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
            .onChange(of: vm.didStartTracking) { _, started in
                if started { dismiss() }
            }
            .alert("錯誤", isPresented: .constant(vm.errorMessage != nil)) {
                Button("確定") { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }

    private var doctorInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.progress.doctorName)
                        .font(.title2.bold())
                    Text("\(vm.hospital.name) · \(vm.progress.department) · \(vm.progress.clinicRoom)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Divider()

            HStack {
                Label("目前叫號", systemImage: "number.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("#\(vm.progress.currentNumber)")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.appGreen)
            }
        }
        .padding()
        .cardStyle()
    }

    private var numberInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("您的掛號號碼")
                .font(.headline)

            HStack {
                TextField("輸入號碼（選填）", text: $vm.userNumberText)
                    .keyboardType(.numberPad)
                    .font(.title2)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                if !vm.userNumberText.isEmpty {
                    Button { vm.userNumberText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let remaining = vm.remaining {
                if remaining > 0 {
                    Label("您是 \(vm.userNumber!) 號，前面還有 \(remaining) 位", systemImage: "person.fill.questionmark")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if remaining == 0 {
                    Label("輪到您了！", systemImage: "bell.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.appGreen)
                } else {
                    Label("您是 \(vm.userNumber!) 號，已超過目前叫號", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
            } else {
                Text("不填寫則僅追蹤進度，不設個人提醒")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var thresholdSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("提醒時機")
                .font(.headline)

            Picker("提醒時機", selection: $vm.threshold) {
                Text("差 10 號").tag(10)
                Text("差 5 號").tag(5)
                Text("差 3 號").tag(3)
                Text("輪到才提醒").tag(1)
            }
            .pickerStyle(.segmented)

            Text("選擇距離叫到您的號碼多近時發送通知")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var startButton: some View {
        Button {
            Task { await vm.startTracking() }
        } label: {
            Group {
                if vm.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Label("開始追蹤", systemImage: "bell.badge.fill")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.appGreen)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(vm.isLoading)
    }
}

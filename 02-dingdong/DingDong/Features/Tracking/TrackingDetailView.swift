import SwiftUI

struct TrackingDetailView: View {
    let task: TrackingTask
    @EnvironmentObject var trackingService: TrackingService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    progressCard
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("追蹤詳情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await trackingService.refreshAllTasks() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(Color.appGreen)
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(task.doctorName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Text("\(task.hospitalName) · \(task.department) · \(task.clinicRoom)")
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cardStyle()
    }

    private var progressCard: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center) {
                numberDisplay(label: "目前叫號", number: task.currentNumber, color: Color.appGreen)

                if let userNumber = task.userNumber {
                    Divider()
                        .frame(height: 60)
                        .overlay(Color.appBorder)
                    numberDisplay(label: "我的號碼", number: userNumber, color: Color.appTextPrimary)

                    if let remaining = task.remaining {
                        Divider()
                            .frame(height: 60)
                            .overlay(Color.appBorder)
                        VStack(spacing: 4) {
                            Text("還差")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Color.appTextSecondary)
                            Text("\(max(remaining, 0))")
                                .font(.system(size: 36, weight: .bold, design: .serif))
                                .foregroundStyle(remaining <= 3 ? Color.appUrgency : Color.appTextPrimary)
                                .contentTransition(.numericText())
                            Text("位")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }

            Text(task.lastUpdated.relativeString)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(16)
        .cardStyle()
    }

    private func numberDisplay(label: String, number: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color.appTextSecondary)
            Text("\(number)")
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        Button {
            trackingService.stopTracking(taskId: task.id)
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "bell.slash.fill")
                Text("停止追蹤")
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.appSurface)
            .foregroundStyle(Color.appTextSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appBorder, lineWidth: 1.5)
            )
        }
    }
}

import SwiftUI

struct TrackingDetailView: View {
    let task: TrackingTask
    @EnvironmentObject var trackingService: TrackingService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                progressCard
                actionButtons
            }
            .padding()
        }
        .navigationTitle("追蹤詳情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await trackingService.refreshAllTasks() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.doctorName)
                .font(.title2.bold())
            Text(task.clinicRoom)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Divider()
            Text("\(task.hospitalName) · \(task.department)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }

    private var progressCard: some View {
        VStack(spacing: 20) {
            HStack {
                numberDisplay(label: "目前號碼", number: task.currentNumber, color: Color.appGreen)

                if let userNumber = task.userNumber {
                    Divider().frame(height: 60)
                    numberDisplay(label: "我的號碼", number: userNumber, color: .primary)

                    if let remaining = task.remaining {
                        Divider().frame(height: 60)
                        VStack(spacing: 4) {
                            Text("剩餘")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(max(remaining, 0))")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(remaining <= 3 ? .red : .orange)
                            Text("號")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }

            Text(task.lastUpdated.relativeString)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .cardStyle()
    }

    private func numberDisplay(label: String, number: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("#\(number)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        Button(role: .destructive) {
            trackingService.stopTracking(taskId: task.id)
            dismiss()
        } label: {
            Label("停止追蹤", systemImage: "bell.slash.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

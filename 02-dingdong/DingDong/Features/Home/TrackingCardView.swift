import SwiftUI

struct TrackingCardView: View {
    let task: TrackingTask
    let onStop: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.doctorName)
                        .font(.headline)
                    Text("\(task.hospitalName) · \(task.department) · \(task.clinicRoom)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onStop) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
            }

            Divider()

            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("目前號碼")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("#\(task.currentNumber)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appGreen)
                }

                Spacer()

                if let userNumber = task.userNumber {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("我的號碼")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("#\(userNumber)")
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                    }

                    if let remaining = task.remaining, remaining > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("剩餘")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(remaining) 號")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundStyle(remaining <= 3 ? .red : .orange)
                        }
                        .padding(.leading, 16)
                    }
                }
            }

            Text(task.lastUpdated.relativeString)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .cardStyle()
    }
}

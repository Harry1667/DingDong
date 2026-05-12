import SwiftUI

struct DoctorProgressCard: View {
    let progress: ClinicProgress
    let onTrack: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(progress.doctorName)
                        .font(.headline)
                    Text(progress.clinicRoom)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.appGreenLight)
                        .foregroundStyle(Color.appGreen)
                        .clipShape(Capsule())
                }

                HStack(spacing: 4) {
                    Text("目前叫號")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("#\(progress.currentNumber)")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.appGreen)

                    if progress.isCurrentSkipped {
                        Text("(過號)")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
            }

            Spacer()

            Button(action: onTrack) {
                Text("追蹤")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.appGreen)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .cardStyle()
    }
}

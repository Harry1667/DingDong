import SwiftUI

struct DoctorProgressCard: View {
    let progress: ClinicProgress
    let onTrack: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(progress.doctorName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(progress.clinicRoom)
                        .font(.system(size: 11, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.appGreenLight)
                        .foregroundStyle(Color.appGreen)
                        .clipShape(Capsule())
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("目前")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary)
                    Text("\(progress.currentNumber)")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(Color.appGreen)
                        .contentTransition(.numericText())

                    if progress.isCurrentSkipped {
                        Text("過號")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color.appUrgency)
                    }
                }
            }

            Spacer()

            Button(action: onTrack) {
                Text("追蹤")
                    .font(.system(size: 13, weight: .semibold))
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

#Preview {
    VStack(spacing: 12) {
        DoctorProgressCard(
            progress: ClinicProgress(department: "內科", doctorName: "王小明", clinicRoom: "診間 03",
                                     currentNumber: 42, nextNumber: 43,
                                     isCurrentSkipped: false, isNextSkipped: false)
        ) {}
        DoctorProgressCard(
            progress: ClinicProgress(department: "外科", doctorName: "李大華", clinicRoom: "診間 07",
                                     currentNumber: 18, nextNumber: 19,
                                     isCurrentSkipped: true, isNextSkipped: false)
        ) {}
    }
    .padding()
    .background(Color.appBackground)
}

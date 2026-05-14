import SwiftUI

struct DoctorProgressCard: View {
    let hospital: Hospital
    let progress: ClinicProgress
    let onTrack: () -> Void

    @EnvironmentObject private var favoriteService: FavoriteService

    private var isFav: Bool {
        favoriteService.isFavorite(hospitalCode: hospital.code,
                                   doctorName: progress.doctorName,
                                   clinicRoom: progress.clinicRoom)
    }

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

            Button {
                favoriteService.toggle(
                    hospitalCode: hospital.code,
                    hospitalName: hospital.name,
                    department: progress.department,
                    doctorName: progress.doctorName,
                    clinicRoom: progress.clinicRoom
                )
            } label: {
                Image(systemName: isFav ? "star.fill" : "star")
                    .font(.system(size: 18))
                    .foregroundStyle(isFav ? Color.appUrgency : Color.appTextSecondary.opacity(0.4))
            }
            .padding(.trailing, 4)

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

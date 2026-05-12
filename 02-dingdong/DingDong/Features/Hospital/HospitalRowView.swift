import SwiftUI

struct HospitalRowView: View {
    let hospital: Hospital

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "cross.case.fill")
                .foregroundStyle(Color.appGreen)
                .frame(width: 36, height: 36)
                .background(Color.appGreenLight)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(hospital.name)
                    .font(.body)
                if let city = hospital.city, let district = hospital.district {
                    Text("\(city) \(district)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if let city = hospital.city {
                    Text(city)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }
}

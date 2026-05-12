import SwiftUI

struct HospitalRowView: View {
    let hospital: Hospital

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appGreenLight)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "cross.case.fill")
                        .foregroundStyle(Color.appGreen)
                        .font(.system(size: 16))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(hospital.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                if let city = hospital.city, let district = hospital.district {
                    Text("\(city) · \(district)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary)
                } else if let city = hospital.city {
                    Text(city)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.appTextSecondary.opacity(0.4))
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

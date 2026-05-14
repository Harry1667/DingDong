import SwiftUI

struct AddFavoriteBrowserSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            HospitalPicker(
                title: "加入常用醫師",
                stepIndex: nil,
                onBack: { dismiss() }
            ) { hospital in
                FavoriteDeptPickerView(hospital: hospital)
            }
        }
    }
}

// MARK: - Department picker (favorites flow)

private struct FavoriteDeptPickerView: View {
    let hospital: Hospital
    @StateObject private var vm: ProgressViewModel
    @Environment(\.dismiss) private var dismiss

    init(hospital: Hospital) {
        self.hospital = hospital
        _vm = StateObject(wrappedValue: ProgressViewModel(hospital: hospital))
    }

    private var allDepartments: [String] {
        Array(Set(vm.progressData.map { $0.department })).sorted()
    }

    var body: some View {
        SimpleScreen {
            SimpleTopBar(title: hospital.name, onBack: { dismiss() })
            Text("選擇科別")
                .font(.system(size: 22, weight: .heavy))
                .tracking(-0.3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        } content: {
            content
        }
        .task { await vm.load() }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading && vm.progressData.isEmpty {
            ProgressView().tint(Color.appAccent)
                .frame(maxWidth: .infinity).padding(.top, 60)
        } else if allDepartments.isEmpty {
            VStack(spacing: 14) {
                Text("📋").font(.system(size: 48))
                Text("今日無看診資料")
                    .font(.system(size: 18, weight: .heavy))
            }
            .padding(.top, 40)
            .frame(maxWidth: .infinity)
        } else {
            SimpleTwoColGrid {
                ForEach(allDepartments, id: \.self) { dept in
                    NavigationLink {
                        FavoriteDoctorListView(
                            hospital: hospital,
                            department: dept,
                            progressVM: vm
                        )
                    } label: {
                        SimpleGridCard(
                            title: dept,
                            isClosed: false,
                            minHeight: 90,
                            action: {}
                        )
                        .allowsHitTesting(false)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 6)
        }
    }
}

// MARK: - Doctor list (favorites flow)

private struct FavoriteDoctorListView: View {
    let hospital: Hospital
    let department: String
    @ObservedObject var progressVM: ProgressViewModel
    @EnvironmentObject private var favoriteService: FavoriteService
    @Environment(\.dismiss) private var dismiss
    @State private var addedId: String?

    private var doctors: [ClinicProgress] {
        progressVM.doctors(for: department)
    }

    var body: some View {
        SimpleScreen {
            SimpleTopBar(title: hospital.name, onBack: { dismiss() })
            Text(department)
                .font(.system(size: 22, weight: .heavy))
                .tracking(-0.3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        } content: {
            VStack(spacing: 10) {
                ForEach(doctors) { doctor in
                    doctorRow(doctor)
                }
            }
            .padding(.top, 6)
        }
    }

    private func doctorRow(_ doctor: ClinicProgress) -> some View {
        let isFav = favoriteService.isFavorite(
            hospitalCode: hospital.code,
            doctorName: doctor.doctorName,
            clinicRoom: doctor.clinicRoom
        )
        let justAdded = addedId == doctor.id

        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(doctor.doctorName)
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(Color.appInk)
                    if !doctor.clinicRoom.isEmpty {
                        Text(doctor.clinicRoom)
                            .font(.system(size: 11, weight: .heavy))
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(Color.appAccentS)
                            .foregroundStyle(Color.appAccentD)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                HStack(spacing: 4) {
                    Text("目前看到")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appInk2)
                    Text("\(doctor.currentNumber)")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(Color.appAccent)
                        .monospacedDigit()
                    Text("號")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color.appAccentD)
                }
            }
            Spacer()
            Button {
                favoriteService.toggle(
                    hospitalCode: hospital.code,
                    hospitalName: hospital.name,
                    department: doctor.department,
                    doctorName: doctor.doctorName,
                    clinicRoom: doctor.clinicRoom
                )
                if !isFav { addedId = doctor.id }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isFav ? "star.fill" : "star")
                        .font(.system(size: 13, weight: .heavy))
                    Text(justAdded ? "已加入" : (isFav ? "常用中" : "加入"))
                        .font(.system(size: 13, weight: .heavy))
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .foregroundStyle(isFav ? .white : Color.appAccentD)
                .background(isFav ? Color.appAccent : Color.appAccentS)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.appAccent, lineWidth: 2))
                .shadow(color: isFav ? Color.appAccentD : .clear, radius: 0, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.2), value: isFav)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .simpleCard(
            radius: 16,
            borderColor: isFav ? Color.appAccent.opacity(0.5) : Color.appBorder,
            borderWidth: isFav ? 2.5 : 2
        )
    }
}

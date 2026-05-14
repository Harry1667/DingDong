import SwiftUI

struct AddFavoriteBrowserSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            HospitalPicker { hospital in
                FavoriteDeptPickerView(hospital: hospital)
            }
            .navigationTitle("加入常用醫師")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("關閉") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }
}

// MARK: - Department picker

private struct FavoriteDeptPickerView: View {
    let hospital: Hospital
    @StateObject private var vm: ProgressViewModel
    @State private var searchText = ""

    init(hospital: Hospital) {
        self.hospital = hospital
        _vm = StateObject(wrappedValue: ProgressViewModel(hospital: hospital))
    }

    private var filteredGroups: [(dept: String, doctors: [ClinicProgress])] {
        guard !searchText.isEmpty else { return vm.groupedByDepartment }
        return vm.groupedByDepartment.filter {
            $0.dept.localizedCaseInsensitiveContains(searchText) ||
            $0.doctors.contains { $0.doctorName.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Group {
                if vm.isLoading && vm.progressData.isEmpty {
                    ProgressView("載入看診資料…").tint(Color.appGreen)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.groupedByDepartment.isEmpty {
                    emptyView
                } else if filteredGroups.isEmpty {
                    noResultsView
                } else {
                    deptList
                }
            }
        }
        .navigationTitle(hospital.name)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "搜尋科別或醫師")
        .task { await vm.load() }
    }

    private var deptList: some View {
        List {
            ForEach(filteredGroups, id: \.dept) { group in
                NavigationLink(destination: FavoriteDoctorListView(
                    hospital: hospital, department: group.dept, progressVM: vm
                )) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(group.dept)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.appTextPrimary)
                        Text("\(group.doctors.count) 位醫師")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .contentShape(Rectangle())
                }
                .listRowBackground(Color.appSurface)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .refreshable { await vm.refresh() }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 44))
                .foregroundStyle(Color.appTextSecondary.opacity(0.4))
            Text("今日無看診資料")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Text("請於開診後再查詢，或選擇其他醫院")
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).padding()
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(Color.appTextSecondary.opacity(0.4))
            Text("找不到「\(searchText)」")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Doctor picker

private struct FavoriteDoctorListView: View {
    let hospital: Hospital
    let department: String
    @ObservedObject var progressVM: ProgressViewModel

    @EnvironmentObject private var favoriteService: FavoriteService
    @State private var addedId: String?
    @State private var searchText = ""

    private var filteredDoctors: [ClinicProgress] {
        let all = progressVM.doctors(for: department)
        guard !searchText.isEmpty else { return all }
        return all.filter {
            $0.doctorName.localizedCaseInsensitiveContains(searchText) ||
            $0.clinicRoom.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            if filteredDoctors.isEmpty && !searchText.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.4))
                    Text("找不到「\(searchText)」")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredDoctors) { doctor in
                            doctorRow(doctor)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationTitle(department)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "搜尋醫師或診間")
    }

    private func doctorRow(_ doctor: ClinicProgress) -> some View {
        let isFav = favoriteService.isFavorite(
            hospitalCode: hospital.code,
            doctorName: doctor.doctorName,
            clinicRoom: doctor.clinicRoom
        )
        let justAdded = addedId == doctor.id

        return HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(doctor.doctorName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(doctor.clinicRoom)
                        .font(.system(size: 10, design: .monospaced))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.appGreenLight)
                        .foregroundStyle(Color.appGreen)
                        .clipShape(Capsule())
                }
                HStack(spacing: 4) {
                    Text("目前叫號")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary)
                    Text("\(doctor.currentNumber)")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(Color.appGreen)
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
                HStack(spacing: 5) {
                    Image(systemName: isFav ? "star.fill" : "star")
                    Text(justAdded ? "已加入" : (isFav ? "常用中" : "加入常用"))
                        .font(.system(size: 12, weight: .semibold))
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(isFav ? Color.appGreen : Color.appGreenLight)
                .foregroundStyle(isFav ? .white : Color.appGreen)
                .clipShape(Capsule())
                .animation(.easeInOut(duration: 0.2), value: isFav)
            }
        }
        .padding(14)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(
            isFav ? Color.appGreen.opacity(0.35) : Color.appBorder, lineWidth: 1
        ))
    }
}

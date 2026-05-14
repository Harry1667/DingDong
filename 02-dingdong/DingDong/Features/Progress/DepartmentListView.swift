import SwiftUI

struct DepartmentListView: View {
    @StateObject private var vm: ProgressViewModel
    @State private var searchText = ""

    init(hospital: Hospital) {
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
                    ProgressView("載入看診資料…")
                        .tint(Color.appGreen)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = vm.errorMessage, vm.progressData.isEmpty {
                    errorView(message: error)
                } else if vm.groupedByDepartment.isEmpty {
                    noDataView
                } else if filteredGroups.isEmpty {
                    noResultsView
                } else {
                    departmentList
                }
            }
        }
        .navigationTitle(vm.hospital.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let updated = vm.lastUpdated {
                    Text(updated.relativeString)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .searchable(text: $searchText, prompt: "搜尋科別或醫師")
        .task { await vm.load() }
    }

    private var departmentList: some View {
        List {
            ForEach(filteredGroups, id: \.dept) { group in
                NavigationLink(destination: DoctorListView(
                    hospital: vm.hospital,
                    department: group.dept,
                    progressVM: vm
                )) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(group.dept)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.appTextPrimary)
                            Text("\(group.doctors.count) 位醫師")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        Spacer()
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

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(Color.appTextSecondary.opacity(0.4))
            Text("找不到「\(searchText)」")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Text("試試搜尋其他科別或醫師")
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noDataView: some View {
        let offHours = !TrackingService.isOperatingHours()
        return VStack(spacing: 16) {
            Image(systemName: offHours ? "moon.zzz" : "calendar.badge.exclamationmark")
                .font(.system(size: 44))
                .foregroundStyle(Color.appTextSecondary.opacity(0.4))
            Text(offHours ? "目前非看診時間" : "今日無看診資料")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Text(offHours ? "看診時間為週一至週六 07:00–21:00\n請於開診後再查詢" : "此醫院今日可能未開診，或資料尚未更新")
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 44))
                .foregroundStyle(Color.appTextSecondary.opacity(0.4))
            Text("載入失敗")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
            Button {
                Task { await vm.load() }
            } label: {
                Text("重試")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.appGreen)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

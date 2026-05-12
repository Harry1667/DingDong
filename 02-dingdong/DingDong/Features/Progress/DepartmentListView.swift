import SwiftUI

struct DepartmentListView: View {
    @StateObject private var vm: ProgressViewModel

    init(hospital: Hospital) {
        _vm = StateObject(wrappedValue: ProgressViewModel(hospital: hospital))
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
        .task { await vm.load() }
    }

    private var departmentList: some View {
        List {
            ForEach(vm.groupedByDepartment, id: \.dept) { group in
                NavigationLink(destination: DoctorListView(
                    hospital: vm.hospital,
                    department: group.dept,
                    doctors: group.doctors,
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

    private var noDataView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 44))
                .foregroundStyle(Color.appTextSecondary.opacity(0.4))
            Text("今日無看診資料")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Text("此醫院今日可能未開診，或資料尚未更新")
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    NavigationStack {
        DepartmentListView(hospital: Hospital(
            code: "NTU", name: "台大醫院", shortName: "台大",
            city: "台北市", district: "中正區", level: "醫學中心", isActive: true
        ))
    }
}

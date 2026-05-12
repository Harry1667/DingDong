import SwiftUI

// 入口：選醫院後呈現科別列表
struct ProgressView: View {
    @StateObject private var vm: ProgressViewModel
    @State private var selectedDepartment: String?

    init(hospital: Hospital) {
        _vm = StateObject(wrappedValue: ProgressViewModel(hospital: hospital))
    }

    var body: some View {
        Group {
            if vm.isLoading && vm.progressData.isEmpty {
                ProgressView("載入看診資料...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = vm.errorMessage, vm.progressData.isEmpty {
                errorView(message: error)
            } else if vm.groupedByDepartment.isEmpty {
                noDataView
            } else {
                departmentList
            }
        }
        .navigationTitle(vm.hospital.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let updated = vm.lastUpdated {
                    Text(updated.relativeString)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
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
                        VStack(alignment: .leading, spacing: 2) {
                            Text(group.dept)
                                .font(.body)
                            Text("\(group.doctors.count) 位醫師")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await vm.refresh() }
    }

    private var noDataView: some View {
        ContentUnavailableView(
            "今日無看診資料",
            systemImage: "calendar.badge.exclamationmark",
            description: Text("此醫院今日可能未開診，或資料尚未更新")
        )
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView(
            "載入失敗",
            systemImage: "wifi.slash",
            description: Text(message)
        )
    }
}

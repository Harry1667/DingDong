import SwiftUI

struct HospitalListView: View {
    @StateObject private var vm = HospitalViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Group {
                if vm.isLoading && vm.allHospitals.isEmpty {
                    ProgressView("載入醫院列表…")
                        .tint(Color.appGreen)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = vm.errorMessage, vm.allHospitals.isEmpty {
                    errorView(message: error)
                } else if vm.isSearching {
                    searchResultsList
                } else if vm.groupedHospitals.isEmpty {
                    emptyView
                } else {
                    groupedList
                }
            }
        }
        .navigationTitle("選擇醫院")
        .searchable(text: $vm.searchText, prompt: "搜尋醫院名稱…")
        .task { await vm.loadHospitals() }
    }

    private var groupedList: some View {
        List {
            ForEach(vm.groupedHospitals, id: \.area) { group in
                Section(group.area.rawValue) {
                    ForEach(group.hospitals) { hospital in
                        NavigationLink(destination: DepartmentListView(hospital: hospital)) {
                            HospitalRowView(hospital: hospital)
                        }
                        .listRowBackground(Color.appSurface)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .refreshable { await vm.reload() }
    }

    private var searchResultsList: some View {
        Group {
            if vm.searchResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.4))
                    Text("找不到「\(vm.searchText)」")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("請嘗試其他關鍵字")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(vm.searchResults) { hospital in
                    NavigationLink(destination: DepartmentListView(hospital: hospital)) {
                        HospitalRowView(hospital: hospital)
                    }
                    .listRowBackground(Color.appSurface)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 44))
                .foregroundStyle(Color.appTextSecondary.opacity(0.4))
            Text("無法載入醫院列表")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
            Button {
                Task { await vm.reload() }
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

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 44))
                .foregroundStyle(Color.appTextSecondary.opacity(0.4))
            Text("目前無可用醫院")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Button {
                Task { await vm.reload() }
            } label: {
                Text("重新整理")
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

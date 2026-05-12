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
                } else if vm.isSearching {
                    searchResultsList
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
}

#Preview {
    HospitalListView()
}

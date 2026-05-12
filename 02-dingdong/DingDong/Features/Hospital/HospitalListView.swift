import SwiftUI

struct HospitalListView: View {
    @StateObject private var vm = HospitalViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.allHospitals.isEmpty {
                    ProgressView("載入醫院列表...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.isSearching {
                    searchResultsList
                } else {
                    groupedList
                }
            }
            .navigationTitle("選擇醫院")
            .searchable(text: $vm.searchText, prompt: "搜尋醫院名稱…")
        }
        .task { await vm.loadHospitals() }
    }

    private var groupedList: some View {
        List {
            ForEach(vm.groupedHospitals, id: \.area) { group in
                Section(group.area.rawValue) {
                    ForEach(group.hospitals) { hospital in
                        NavigationLink(destination: ProgressView(hospital: hospital)) {
                            HospitalRowView(hospital: hospital)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var searchResultsList: some View {
        Group {
            if vm.searchResults.isEmpty {
                ContentUnavailableView.search(text: vm.searchText)
            } else {
                List(vm.searchResults) { hospital in
                    NavigationLink(destination: ProgressView(hospital: hospital)) {
                        HospitalRowView(hospital: hospital)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}

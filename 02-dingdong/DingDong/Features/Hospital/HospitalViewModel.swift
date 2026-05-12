import Foundation
import Combine

@MainActor
final class HospitalViewModel: ObservableObject {
    @Published var allHospitals: [Hospital] = []
    @Published var searchResults: [Hospital] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    var groupedHospitals: [(area: HospitalArea, hospitals: [Hospital])] {
        let grouped = Dictionary(grouping: allHospitals, by: HospitalArea.classify)
        return HospitalArea.allCases.compactMap { area in
            guard let hospitals = grouped[area], !hospitals.isEmpty else { return nil }
            return (area: area, hospitals: hospitals)
        }
    }

    var isSearching: Bool { !searchText.isEmpty }

    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.performSearch(text: text)
            }
            .store(in: &cancellables)
    }

    func loadHospitals() async {
        guard allHospitals.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            allHospitals = try await HospitalService.shared.fetchHospitals()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func performSearch(text: String) {
        searchTask?.cancel()
        guard !text.isEmpty else { searchResults = []; return }

        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 0)
                let results = try await HospitalService.shared.searchHospitals(query: text)
                guard !Task.isCancelled else { return }
                searchResults = results
            } catch {
                if !Task.isCancelled {
                    // 搜尋失敗時，從本地過濾
                    searchResults = allHospitals.filter { $0.name.contains(text) }
                }
            }
        }
    }
}

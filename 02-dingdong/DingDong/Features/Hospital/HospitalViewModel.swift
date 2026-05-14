import Foundation
import Combine

@MainActor
final class HospitalViewModel: ObservableObject {
    @Published var allHospitals: [Hospital] = []
    @Published var searchResults: [Hospital] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

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
            .sink { [weak self] text in
                self?.performSearch(text: text)
            }
            .store(in: &cancellables)
    }

    func loadHospitals() async {
        guard allHospitals.isEmpty else { return }
        await reload()
    }

    func reload() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            allHospitals = try await HospitalService.shared.fetchHospitals(forceRefresh: true)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func performSearch(text: String) {
        guard !text.isEmpty else { searchResults = []; return }
        searchResults = allHospitals.filter {
            $0.name.localizedCaseInsensitiveContains(text) ||
            ($0.shortName?.localizedCaseInsensitiveContains(text) ?? false)
        }
    }
}

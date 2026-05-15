import Foundation
import Combine

@MainActor
final class HospitalViewModel: ObservableObject {
    @Published var allHospitals: [Hospital] = []
    @Published var searchResults: [Hospital] = []
    @Published var hospitalStatus: [String: Bool] = [:]   // code → isOpen
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    private var cancellables = Set<AnyCancellable>()
    private var statusTimer: Timer?

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
            async let listTask = HospitalService.shared.fetchHospitals(forceRefresh: true)
            async let statusTask = HospitalService.shared.fetchHospitalStatus()
            allHospitals = try await listTask
            hospitalStatus = await statusTask
            startAutoRefreshStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshStatus() async {
        hospitalStatus = await HospitalService.shared.fetchHospitalStatus()
    }

    private func startAutoRefreshStatus() {
        statusTimer?.invalidate()
        statusTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { await self?.refreshStatus() }
        }
    }

    deinit {
        statusTimer?.invalidate()
    }

    private func performSearch(text: String) {
        guard !text.isEmpty else { searchResults = []; return }
        searchResults = allHospitals.filter {
            $0.name.localizedCaseInsensitiveContains(text) ||
            ($0.shortName?.localizedCaseInsensitiveContains(text) ?? false)
        }
    }
}

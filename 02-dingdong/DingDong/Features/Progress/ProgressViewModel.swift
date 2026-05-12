import Foundation
import Combine

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var progressData: [ClinicProgress] = []
    @Published var departments: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?

    let hospital: Hospital
    private var refreshTimer: Timer?

    init(hospital: Hospital) {
        self.hospital = hospital
    }

    var groupedByDepartment: [(dept: String, doctors: [ClinicProgress])] {
        let grouped = Dictionary(grouping: progressData, by: { $0.department })
        return grouped
            .map { (dept: $0.key, doctors: $0.value) }
            .sorted { $0.dept < $1.dept }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        await refresh()
        startAutoRefresh()
    }

    func refresh() async {
        do {
            let response = try await HospitalService.shared.fetchProgress(hospitalCode: hospital.code)
            progressData = response.data
            departments = Array(Set(response.data.map { $0.department })).sorted()
            lastUpdated = Date()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func doctors(for department: String) -> [ClinicProgress] {
        progressData.filter { $0.department == department }
    }

    private func startAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { await self?.refresh() }
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }
}

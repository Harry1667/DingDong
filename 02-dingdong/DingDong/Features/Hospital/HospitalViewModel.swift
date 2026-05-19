import Foundation
import Combine

@MainActor
final class HospitalViewModel: ObservableObject {
    @Published var allHospitals: [Hospital] = []
    @Published var searchResults: [Hospital] = []
    @Published var hospitalStatus: [String: Bool] = [:]   // code → isOpen
    /// 院區層級 open（vid → isOpen），用 progress 資料依 prefix 算出。
    /// 例：`tsgh:台北門` 若該前綴下沒任何 dept 即為 false，但 `tsgh` 整體可能仍是 open=true。
    @Published var branchOpenStatus: [String: Bool] = [:]
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
            await refreshBranchStatus()
            startAutoRefreshStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshStatus() async {
        hospitalStatus = await HospitalService.shared.fetchHospitalStatus()
        await refreshBranchStatus()
    }

    /// 針對有院區拆分的醫院（SimpleHospital.splits），依 prefix 看實際 progress 有沒有對應 dept，
    /// 補一份 vid → open 的精確判斷。沒資料的院區會被標為休診，避免 HospitalPicker 顯示可點卻進去空白。
    private func refreshBranchStatus() async {
        var result: [String: Bool] = [:]
        for (code, splits) in SimpleHospital.splits {
            // 整間醫院已休診，所有院區一起標休診
            if hospitalStatus[code] == false {
                for s in splits { result[s.vid] = false }
                continue
            }
            do {
                let prog = try await HospitalService.shared.fetchProgress(hospitalCode: code)
                let depts = prog.data.map { $0.department }
                for s in splits {
                    result[s.vid] = depts.contains { $0.hasPrefix(s.prefix) }
                }
            } catch {
                // fetch 失敗就不覆蓋，沿用 hospitalStatus 的 code-level 判斷
            }
        }
        branchOpenStatus = result
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

import Foundation

actor HospitalService {
    static let shared = HospitalService()
    private init() {}

    func fetchHospitals(forceRefresh: Bool = false) async throws -> [Hospital] {
        if !forceRefresh, let cached = PersistenceService.shared.cachedHospitals {
            return cached
        }
        let response: HospitalsResponse = try await APIClient.shared.get(APIEndpoints.hospitals())
        let active = response.hospitals.filter { $0.isActive }
        PersistenceService.shared.cachedHospitals = active
        return active
    }

    func searchHospitals(query: String) async throws -> [Hospital] {
        let response: HospitalSearchResponse = try await APIClient.shared.get(
            APIEndpoints.searchHospital(query: query)
        )
        return response.results
    }

    func fetchProgress(hospitalCode: String) async throws -> ProgressResponse {
        try await APIClient.shared.get(APIEndpoints.progress(hospitalCode: hospitalCode))
    }

    /// 取得每間醫院當下「是否有任一科開診」的狀態（對齊網頁 /api/hospitals/status）。
    /// 回傳 `[code: isOpen]`；任何錯誤都回空字典讓上層默默 fallback。
    func fetchHospitalStatus() async -> [String: Bool] {
        do {
            let response: HospitalStatusResponse = try await APIClient.shared.get(
                APIEndpoints.hospitalsStatus()
            )
            return response.hospitals.mapValues { $0.open }
        } catch {
            return [:]
        }
    }

    func fetchDepartments(hospitalCode: String) async throws -> [Department] {
        let response: DepartmentsResponse = try await APIClient.shared.get(
            APIEndpoints.departments(hospitalCode: hospitalCode)
        )
        return response.departments
    }
}

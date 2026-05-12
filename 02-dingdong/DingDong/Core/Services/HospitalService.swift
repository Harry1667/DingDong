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
        return response.hospitals
    }

    func fetchProgress(hospitalCode: String) async throws -> ProgressResponse {
        try await APIClient.shared.get(APIEndpoints.progress(hospitalCode: hospitalCode))
    }

    func fetchDepartments(hospitalCode: String) async throws -> [Department] {
        let response: DepartmentsResponse = try await APIClient.shared.get(
            APIEndpoints.departments(hospitalCode: hospitalCode)
        )
        return response.departments
    }
}

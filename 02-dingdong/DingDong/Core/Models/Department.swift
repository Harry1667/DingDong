import Foundation

struct Department: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let category: String?
}

struct DepartmentsResponse: Codable {
    let departments: [Department]
}

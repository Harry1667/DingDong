import Foundation

struct ProgressResponse: Codable {
    let hospital: String
    let code: String
    let count: Int
    let data: [ClinicProgress]
}

struct ClinicProgress: Codable, Identifiable, Hashable {
    var id: String { "\(department)-\(doctorName)-\(clinicRoom)" }
    let department: String
    let doctorName: String
    let clinicRoom: String
    let currentNumber: Int
    let nextNumber: Int
    let isCurrentSkipped: Bool
    let isNextSkipped: Bool

    enum CodingKeys: String, CodingKey {
        case department
        case doctorName       = "doctor_name"
        case clinicRoom       = "clinic_room"
        case currentNumber    = "current_number"
        case nextNumber       = "next_number"
        case isCurrentSkipped = "is_current_skipped"
        case isNextSkipped    = "is_next_skipped"
    }
}

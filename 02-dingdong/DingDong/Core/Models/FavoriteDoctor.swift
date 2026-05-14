import Foundation

struct FavoriteDoctor: Codable, Identifiable {
    let id: UUID
    let hospitalCode: String
    let hospitalName: String
    let department: String
    let doctorName: String
    let clinicRoom: String
    let addedAt: Date
}

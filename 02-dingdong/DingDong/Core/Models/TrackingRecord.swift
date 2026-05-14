import Foundation

struct TrackingRecord: Codable, Identifiable {
    let id: UUID
    let hospitalName: String
    let doctorName: String
    let clinicRoom: String
    let date: Date
    let userNumber: Int?
    let finalNumber: Int
    let endReason: String   // "notified" / "finished" / "cancelled"
}

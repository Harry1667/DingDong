import Foundation

struct TrackingTask: Codable, Identifiable {
    let id: UUID
    var dbId: Int?

    let hospitalCode: String
    let hospitalName: String
    let department: String
    let doctorName: String
    let clinicRoom: String

    let userNumber: Int?
    let threshold: Int

    var scheduledDate: Date?   // nil = 今天立即啟動

    var currentNumber: Int
    var lastUpdated: Date
    var status: TrackingStatus

    var skippedReminderCount: Int = 0

    var remaining: Int? {
        guard let userNumber else { return nil }
        return userNumber - currentNumber
    }

    var isFinished: Bool {
        status == .finished || status == .cancelled || status == .notified
    }

    // 是否還在等待預約日期
    var isScheduledForFuture: Bool {
        guard status == .scheduled, let date = scheduledDate else { return false }
        return date > Calendar.current.startOfDay(for: Date())
    }
}

enum TrackingStatus: String, Codable {
    case scheduled  // 預約中，等待開診日
    case active     // 追蹤中
    case notified   // 已通知輪到
    case skipped    // 已過號
    case finished   // 看診結束
    case cancelled  // 使用者停止
}

// MARK: - API Request / Response

struct TrackStartRequest: Encodable {
    let guestId: String
    let hospitalCode: String
    let department: String
    let doctorName: String
    let clinicRoom: String
    let session: String?
    let userNumber: Int
    let apnsToken: String?

    enum CodingKeys: String, CodingKey {
        case guestId      = "guest_id"
        case hospitalCode = "hospital_code"
        case department
        case doctorName   = "doctor_name"
        case clinicRoom   = "clinic_room"
        case session
        case userNumber   = "user_number"
        case apnsToken    = "apns_token"
    }
}

struct TrackStartResponse: Codable {
    let ok: Bool
    let trackId: Int?

    enum CodingKeys: String, CodingKey {
        case ok
        case trackId = "track_id"
    }
}

struct TrackStopRequest: Encodable {
    let guestId: String
    let reason: String

    enum CodingKeys: String, CodingKey {
        case guestId = "guest_id"
        case reason
    }
}

struct TrackStopResponse: Codable {
    let ok: Bool
}

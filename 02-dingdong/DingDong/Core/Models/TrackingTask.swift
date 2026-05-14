import Foundation

// 每次叫號更新時紀錄一筆，用來估算候診速度
struct NumberSnapshot: Codable {
    let number: Int
    let timestamp: Date
}

struct TrackingTask: Identifiable {
    let id: UUID
    var dbId: Int?

    let hospitalCode: String
    let hospitalName: String
    let department: String
    let doctorName: String
    let clinicRoom: String

    let userNumber: Int?
    let threshold: Int

    var scheduledDate: Date?

    var currentNumber: Int
    var lastUpdated: Date
    var status: TrackingStatus

    var skippedReminderCount: Int = 0
    var startedAt: Date = Date()
    var numberHistory: [NumberSnapshot] = []

    // MARK: - Computed

    var remaining: Int? {
        guard let userNumber else { return nil }
        return userNumber - currentNumber
    }

    var isFinished: Bool {
        status == .finished || status == .cancelled || status == .notified
    }

    var isScheduledForFuture: Bool {
        guard status == .scheduled, let date = scheduledDate else { return false }
        return date > Calendar.current.startOfDay(for: Date())
    }

    // 根據近期叫號速度估算剩餘分鐘數（需至少 2 筆歷史）
    var estimatedMinutes: Int? {
        guard let remaining = remaining, remaining > 0,
              numberHistory.count >= 2 else { return nil }

        var totalSeconds: Double = 0
        var totalNumbers: Int = 0

        for i in 1..<numberHistory.count {
            let dn = numberHistory[i].number - numberHistory[i - 1].number
            let dt = numberHistory[i].timestamp.timeIntervalSince(numberHistory[i - 1].timestamp)
            guard dn > 0, dt > 0 else { continue }
            totalSeconds += dt
            totalNumbers += dn
        }

        guard totalNumbers > 0 else { return nil }
        let avgSec = totalSeconds / Double(totalNumbers)
        let mins = Int(avgSec * Double(remaining) / 60)
        return mins > 0 ? mins : nil
    }
}

// MARK: - Codable（手動實作以向下相容舊資料）

extension TrackingTask: Codable {
    enum CodingKeys: String, CodingKey {
        case id, dbId, hospitalCode, hospitalName, department, doctorName, clinicRoom
        case userNumber, threshold, scheduledDate, currentNumber, lastUpdated, status
        case skippedReminderCount, startedAt, numberHistory
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                   = try  c.decode(UUID.self,          forKey: .id)
        dbId                 = try? c.decode(Int.self,           forKey: .dbId)
        hospitalCode         = try  c.decode(String.self,        forKey: .hospitalCode)
        hospitalName         = try  c.decode(String.self,        forKey: .hospitalName)
        department           = try  c.decode(String.self,        forKey: .department)
        doctorName           = try  c.decode(String.self,        forKey: .doctorName)
        clinicRoom           = try  c.decode(String.self,        forKey: .clinicRoom)
        userNumber           = try? c.decode(Int.self,           forKey: .userNumber)
        threshold            = try  c.decode(Int.self,           forKey: .threshold)
        scheduledDate        = try? c.decode(Date.self,          forKey: .scheduledDate)
        currentNumber        = try  c.decode(Int.self,           forKey: .currentNumber)
        lastUpdated          = try  c.decode(Date.self,          forKey: .lastUpdated)
        status               = try  c.decode(TrackingStatus.self, forKey: .status)
        skippedReminderCount = (try? c.decode(Int.self,              forKey: .skippedReminderCount)) ?? 0
        startedAt            = (try? c.decode(Date.self,             forKey: .startedAt))            ?? Date()
        numberHistory        = (try? c.decode([NumberSnapshot].self, forKey: .numberHistory))        ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,                   forKey: .id)
        try c.encodeIfPresent(dbId,        forKey: .dbId)
        try c.encode(hospitalCode,         forKey: .hospitalCode)
        try c.encode(hospitalName,         forKey: .hospitalName)
        try c.encode(department,           forKey: .department)
        try c.encode(doctorName,           forKey: .doctorName)
        try c.encode(clinicRoom,           forKey: .clinicRoom)
        try c.encodeIfPresent(userNumber,  forKey: .userNumber)
        try c.encode(threshold,            forKey: .threshold)
        try c.encodeIfPresent(scheduledDate, forKey: .scheduledDate)
        try c.encode(currentNumber,        forKey: .currentNumber)
        try c.encode(lastUpdated,          forKey: .lastUpdated)
        try c.encode(status,               forKey: .status)
        try c.encode(skippedReminderCount, forKey: .skippedReminderCount)
        try c.encode(startedAt,            forKey: .startedAt)
        try c.encode(numberHistory,        forKey: .numberHistory)
    }
}

// MARK: - Status

enum TrackingStatus: String, Codable {
    case scheduled  // 預約中，等待開診日
    case active     // 追蹤中
    case notified   // 已通知輪到
    case skipped    // 已過號
    case finished   // 看診結束
    case cancelled  // 使用者停止
}

// MARK: - API

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

import Foundation
import Security

final class PersistenceService {
    static let shared = PersistenceService()
    private init() {}

    private let defaults = UserDefaults(suiteName: "group.com.ajz.dingdong") ?? UserDefaults.standard

    // MARK: - Tracking Tasks

    var trackingTasks: [TrackingTask] {
        get {
            guard let data = defaults.data(forKey: "tracking_tasks"),
                  let tasks = try? JSONDecoder().decode([TrackingTask].self, from: data) else {
                return []
            }
            return tasks
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: "tracking_tasks")
        }
    }

    // MARK: - Settings

    var notifyThreshold: Int {
        get { defaults.integer(forKey: "notify_threshold").nonZero ?? 5 }
        set { defaults.set(newValue, forKey: "notify_threshold") }
    }

    var notifyMode: NotifyMode {
        get {
            let raw = defaults.string(forKey: "notify_mode") ?? "light"
            return NotifyMode(rawValue: raw) ?? .light
        }
        set { defaults.set(newValue.rawValue, forKey: "notify_mode") }
    }

    var refreshInterval: Int {
        get { defaults.integer(forKey: "refresh_interval").nonZero ?? 30 }
        set { defaults.set(newValue, forKey: "refresh_interval") }
    }

    var hapticEnabled: Bool {
        get {
            guard defaults.object(forKey: "haptic_enabled") != nil else { return true }
            return defaults.bool(forKey: "haptic_enabled")
        }
        set { defaults.set(newValue, forKey: "haptic_enabled") }
    }

    var onboardingDone: Bool {
        get { defaults.bool(forKey: "onboarding_done") }
        set { defaults.set(newValue, forKey: "onboarding_done") }
    }

    // MARK: - Hospital Cache

    var cachedHospitals: [Hospital]? {
        get {
            guard let data = defaults.data(forKey: "hospitals_cache"),
                  let date = defaults.object(forKey: "hospitals_cache_date") as? Date,
                  Date().timeIntervalSince(date) < 86400 else { return nil }
            return try? JSONDecoder().decode([Hospital].self, from: data)
        }
        set {
            if let hospitals = newValue,
               let data = try? JSONEncoder().encode(hospitals) {
                defaults.set(data, forKey: "hospitals_cache")
                defaults.set(Date(), forKey: "hospitals_cache_date")
            } else {
                defaults.removeObject(forKey: "hospitals_cache")
                defaults.removeObject(forKey: "hospitals_cache_date")
            }
        }
    }

    // MARK: - Favourite Doctors

    var favoriteDoctors: [FavoriteDoctor] {
        get {
            guard let data = defaults.data(forKey: "favorite_doctors"),
                  let favs = try? JSONDecoder().decode([FavoriteDoctor].self, from: data) else { return [] }
            return favs
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: "favorite_doctors")
        }
    }

    func toggleFavorite(hospitalCode: String, hospitalName: String, department: String,
                        doctorName: String, clinicRoom: String) {
        var favs = favoriteDoctors
        if let idx = favs.firstIndex(where: {
            $0.hospitalCode == hospitalCode && $0.doctorName == doctorName && $0.clinicRoom == clinicRoom
        }) {
            favs.remove(at: idx)
        } else {
            favs.append(FavoriteDoctor(
                id: UUID(), hospitalCode: hospitalCode, hospitalName: hospitalName,
                department: department, doctorName: doctorName, clinicRoom: clinicRoom,
                addedAt: Date()
            ))
        }
        favoriteDoctors = favs
    }

    func removeFavorite(id: UUID) {
        favoriteDoctors = favoriteDoctors.filter { $0.id != id }
    }

    // MARK: - Pick Count（用於 hospital / dept / doctor 卡片上的「常選」星號）

    private func pickKey(_ kind: String, scope: String, item: String? = nil) -> String {
        let suffix = item.map { ":\($0)" } ?? ""
        return "pick_\(kind):\(scope)\(suffix)"
    }

    func pickCount(kind: String, scope: String, item: String? = nil) -> Int {
        defaults.integer(forKey: pickKey(kind, scope: scope, item: item))
    }

    func bumpPick(kind: String, scope: String, item: String? = nil) {
        let key = pickKey(kind, scope: scope, item: item)
        defaults.set(defaults.integer(forKey: key) + 1, forKey: key)
    }

    // MARK: - Tracking History

    var trackingHistory: [TrackingRecord] {
        get {
            guard let data = defaults.data(forKey: "tracking_history"),
                  let records = try? JSONDecoder().decode([TrackingRecord].self, from: data) else { return [] }
            return records
        }
        set {
            let trimmed = Array(newValue.suffix(50))   // 最多保留 50 筆
            defaults.set(try? JSONEncoder().encode(trimmed), forKey: "tracking_history")
        }
    }

    func appendHistory(_ record: TrackingRecord) {
        var history = trackingHistory
        history.append(record)
        trackingHistory = history
    }

    // MARK: - Guest ID (Keychain)

    var guestId: String {
        if let existing = keychainRead(key: "com.ajz.dingdong.guestId") {
            return existing
        }
        let new = generateGuestId()
        keychainWrite(key: "com.ajz.dingdong.guestId", value: new)
        return new
    }

    private func generateGuestId() -> String {
        let ts = String(Int(Date().timeIntervalSince1970), radix: 36)
        let rand = String((0..<6).map { _ in "abcdefghijklmnopqrstuvwxyz0123456789".randomElement()! })
        return "g_\(ts)_\(rand)"
    }

    private func keychainRead(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func keychainWrite(key: String, value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String:   data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
}

// MARK: - Helpers

enum NotifyMode: String, Codable, CaseIterable {
    case light  = "light"
    case normal = "normal"
    case final_ = "final"

    var displayName: String {
        switch self {
        case .light:  return "重要時機提醒"
        case .normal: return "每次更新提醒"
        case .final_: return "輪到時才提醒"
        }
    }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}

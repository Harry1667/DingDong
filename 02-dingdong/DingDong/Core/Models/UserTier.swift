import Foundation

/// 訂閱層級（對齊網頁 /simple 的 dd_tier）
/// - free：同時追蹤 1 個
/// - paid：同時追蹤 3 個（Pro）
enum UserTier: String, Codable {
    case free
    case paid

    var trackLimit: Int {
        switch self {
        case .free: return 1
        case .paid: return 3
        }
    }

    var label: String {
        switch self {
        case .free: return "免費版"
        case .paid: return "Pro"
        }
    }
}

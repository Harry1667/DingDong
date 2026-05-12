import SwiftUI

extension Color {
    // MARK: - Brand
    static let appGreen      = Color(hex: "#2D6A4F")   // 深森林綠 · accent / active
    static let appGreenMid   = Color(hex: "#3DAB7A")   // 中綠 · 進度條
    static let appGreenLight = Color(hex: "#2D6A4F").opacity(0.10)

    // MARK: - Background & Surface
    static let appBackground = Color(hex: "#F5F0E8")   // 奶油底
    static let appSurface    = Color(hex: "#FDFAF4")   // 卡片

    // MARK: - Text
    static let appTextPrimary   = Color(hex: "#1C1A16") // 暖近黑
    static let appTextSecondary = Color(hex: "#8C7E6A") // 暖灰

    // MARK: - Urgency
    static let appUrgency = Color(hex: "#E8A020")      // 琥珀金 · 差3號以內

    // MARK: - Border / Shadow
    static let appBorder = Color(hex: "#1C1A16").opacity(0.08)

    // MARK: - Legacy alias (keeps existing call sites compiling)
    static let cardBackground = Color.appSurface
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let int = UInt64(hex, radix: 16) ?? 0
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double((int      ) & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

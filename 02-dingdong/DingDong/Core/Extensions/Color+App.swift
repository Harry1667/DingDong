import SwiftUI

extension Color {
    // MARK: - 主背景 / 卡片
    static let appBg        = Color(hex: "#FAF6EE")   // 暖奶油底色
    static let appCard      = Color(hex: "#FFFFFF")
    static let appCardWarm  = Color(hex: "#FDF3D9")   // 進行中 / hero 用
    static let appBorder    = Color(hex: "#E3DCC9")
    static let appBorder2   = Color(hex: "#EFEAD9")

    // MARK: - 文字 / 墨色
    static let appInk       = Color(hex: "#1A2B4A")
    static let appInk2      = Color(hex: "#6A7286")
    static let appInk3      = Color(hex: "#8A8F9E")
    static let appInkSoft   = Color(hex: "#4A536B")

    // MARK: - Accent 橘色（主要 CTA / 數字）
    static let appAccent    = Color(hex: "#FF6B1A")
    static let appAccentD   = Color(hex: "#C24C0E")
    static let appAccentDD  = Color(hex: "#8E3808")
    static let appAccentS   = Color(hex: "#FFE9D8")
    static let appAccentR   = Color(hex: "#FFD0B0")

    // MARK: - 成功（深綠）/ 警示（紅）
    static let appOk        = Color(hex: "#1B5E3A")
    static let appOkD       = Color(hex: "#124025")
    static let appOkS       = Color(hex: "#E8F9EE")
    static let appOkD2      = Color(hex: "#027A40")

    static let appDanger    = Color(hex: "#D94848")
    static let appDangerD   = Color(hex: "#9E2E2E")
    static let appDangerS   = Color(hex: "#FDE3E3")

    // MARK: - 灰底（休診 / disabled）
    static let appClosed    = Color(hex: "#F2ECD9")
    static let appClosedTag = Color(hex: "#8A8F9E")
    static let appDisabled  = Color(hex: "#D8CFB8")

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

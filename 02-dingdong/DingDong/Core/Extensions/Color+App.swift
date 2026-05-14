import SwiftUI

extension Color {
    // MARK: - Brand (fixed — same in both modes)
    static let appGreen      = Color(hex: "#2D6A4F")
    static let appGreenMid   = Color(hex: "#3DAB7A")
    static let appGreenLight = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.176, green: 0.416, blue: 0.31, alpha: 0.22)
            : UIColor(red: 0.176, green: 0.416, blue: 0.31, alpha: 0.10)
    })
    static let appUrgency = Color(hex: "#E8A020")

    // MARK: - Adaptive backgrounds
    static let appBackground = Color(UIColor.systemBackground)
    static let appSurface    = Color(UIColor.secondarySystemBackground)

    // MARK: - Adaptive text
    static let appTextPrimary   = Color(UIColor.label)
    static let appTextSecondary = Color(UIColor.secondaryLabel)

    // MARK: - Adaptive border
    static let appBorder = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 1.0, alpha: 0.10)
            : UIColor(white: 0.0, alpha: 0.08)
    })

    // MARK: - Legacy alias
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

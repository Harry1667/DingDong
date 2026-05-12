import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(red: 0.545, green: 0.431, blue: 0.314).opacity(0.12),
                    radius: 12, x: 0, y: 2)
    }

    func loadingOverlay(_ isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
            }
        }
    }
}

// MARK: - Typography helpers
extension Font {
    // Noto Serif TC Bold — hero queue number
    static func queueNumber(size: CGFloat = 96) -> Font {
        .custom("NotoSerifTC-Bold", size: size)
            .weight(.bold)
    }
    // DM Mono — timestamps, deltas, ticket numbers
    static func monoData(size: CGFloat = 13) -> Font {
        .custom("DMSans-Regular", size: size)
    }
}

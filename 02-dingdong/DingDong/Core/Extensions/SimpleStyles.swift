import SwiftUI

// MARK: - Region (北/中/南)

enum SimpleRegion: String, CaseIterable, Identifiable {
    case north, central, south
    var id: String { rawValue }
    var label: String {
        switch self {
        case .north:   return "北部"
        case .central: return "中部"
        case .south:   return "南部"
        }
    }

    /// 依 HospitalArea 映射為 /simple 的三大區
    static func of(_ area: HospitalArea) -> SimpleRegion {
        switch area {
        case .taipei, .newTaipei, .keelung, .taoyuan:
            return .north
        case .taichung:
            return .central
        case .yunjiaNan, .kaohsiung, .other:
            return .south
        }
    }
}

// MARK: - 卡片：白底厚邊框 + 立體陰影

struct SimpleCardStyle: ViewModifier {
    var radius: CGFloat = 18
    var background: Color = .appCard
    var borderColor: Color = .appBorder
    var borderWidth: CGFloat = 2.5
    var shadowDepth: CGFloat = 2

    func body(content: Content) -> some View {
        content
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 0, x: 0, y: shadowDepth)
    }
}

extension View {
    func simpleCard(radius: CGFloat = 18,
                    background: Color = .appCard,
                    borderColor: Color = .appBorder,
                    borderWidth: CGFloat = 2.5,
                    shadowDepth: CGFloat = 2) -> some View {
        modifier(SimpleCardStyle(
            radius: radius, background: background,
            borderColor: borderColor, borderWidth: borderWidth,
            shadowDepth: shadowDepth
        ))
    }
}

// MARK: - 主要按鈕：橘底白字 + 底部 4px 陰影（立體感）

struct SimplePrimaryButton: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var height: CGFloat = 76
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon, !isLoading {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .bold))
                }
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    VStack(spacing: 2) {
                        Text(title)
                            .font(.system(size: 22, weight: .heavy))
                            .tracking(1)
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 13, weight: .semibold))
                                .opacity(0.92)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [Color.appAccent, Color.appAccentD],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.appAccentDD.opacity(isPressed ? 0 : 1))
                    .frame(height: 4)
                    .offset(y: isPressed ? 2 : 4)
                    .blur(radius: 0.5),
                alignment: .bottom
            )
            .offset(y: isPressed ? 2 : 0)
            .opacity(isDisabled ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - 次要按鈕：白底厚邊框

struct SimpleSecondaryButton: View {
    let title: String
    var icon: String? = nil
    var height: CGFloat = 52
    var role: SimpleButtonRole = .neutral
    let action: () -> Void

    enum SimpleButtonRole { case neutral, danger }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 15, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .foregroundStyle(role == .danger ? Color.appDangerD : Color.appInk)
            .background(Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(role == .danger ? Color.appDangerS : Color.appBorder, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 返回按鈕（取代 navigation back，視覺要厚實）

struct SimpleBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("‹")
                    .font(.system(size: 26, weight: .heavy))
                    .padding(.bottom, 4)
                Text("返回")
                    .font(.system(size: 17, weight: .bold))
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .foregroundStyle(Color.appInk)
            .background(Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appBorder, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 標題列（返回 + 品牌名）

struct SimpleTopBar: View {
    var title: String? = nil
    var onBack: (() -> Void)?

    var body: some View {
        HStack {
            if let onBack {
                SimpleBackButton(action: onBack)
            }
            Spacer()
            Text(title ?? "叮咚到號")
                .font(.system(size: 18, weight: .heavy))
                .tracking(1)
                .foregroundStyle(Color.appInk)
        }
        .frame(height: 44)
    }
}

// MARK: - 步驟標題（大標題 + 第 N 步，共 4 步）

struct SimpleStepTitle: View {
    let title: String
    let step: Int
    let total: Int
    var stepSuffix: String? = nil   // 例如「眼科 · 第 3 步…」

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 22, weight: .heavy))
                .tracking(-0.5)
                .foregroundStyle(Color.appInk)
            HStack(spacing: 4) {
                if let stepSuffix {
                    Text(stepSuffix)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.appAccentD)
                    Text("·")
                        .foregroundStyle(Color.appInk2)
                }
                Text("第 \(step) 步，共 \(total) 步")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.appInk2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }
}

// MARK: - 區域 Tab（北 / 中 / 南）

struct SimpleRegionTabs: View {
    @Binding var selection: SimpleRegion
    let counts: [SimpleRegion: Int]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(SimpleRegion.allCases) { region in
                Button {
                    selection = region
                } label: {
                    VStack(spacing: 1) {
                        Text(region.label)
                            .font(.system(size: 20, weight: .heavy))
                            .tracking(1)
                        Text("\(counts[region] ?? 0) 家")
                            .font(.system(size: 12, weight: .semibold))
                            .opacity(0.75)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .foregroundStyle(selection == region ? .white : Color.appInk)
                    .background(selection == region ? Color.appInk : Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selection == region ? Color.appInk : Color.appBorder,
                                    lineWidth: 2)
                    )
                    .shadow(color: selection == region
                        ? Color.black.opacity(0.12) : .clear, radius: 0, x: 0, y: 3)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - 二欄卡片用容器（grid）

struct SimpleTwoColGrid<Content: View>: View {
    @ViewBuilder var content: () -> Content
    private let cols = [GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)]
    var body: some View {
        LazyVGrid(columns: cols, spacing: 12, content: content)
    }
}

// MARK: - 醫院 / 科別 卡（兩欄）

struct SimpleGridCard: View {
    let title: String
    var branch: String? = nil
    var subtitle: String? = nil
    var isClosed: Bool = false
    var closedLabel: String = "休診"
    var trailingMark: String? = nil       // 星號標記（• / ⭐）
    var nowNumber: Int? = nil             // 顯示「目前看到 N 號」橘框
    var nowEmptyText: String? = nil       // 沒號碼時的訊息（淺灰框）
    var minHeight: CGFloat = 112
    /// 保留供舊呼叫端傳空 closure；本 view 不再自帶點擊，由外層 NavigationLink/Button 控制。
    var action: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleBlock
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isClosed ? Color.appInk3 : Color.appInkSoft)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
            if nowNumber != nil || nowEmptyText != nil {
                nowBox
                    .padding(.top, 6)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: minHeight, alignment: .topLeading)
        .padding(14)
        .opacity(isClosed ? 0.72 : 1)
        .contentShape(Rectangle())
        .simpleCard(
            radius: 20,
            background: isClosed ? Color.appClosed : Color.appCard,
            borderColor: Color.appBorder,
            borderWidth: 2.5
        )
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .heavy))
                    .tracking(-0.3)
                    .foregroundStyle(isClosed ? Color.appInk3 : Color.appInk)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                if let trailingMark, !trailingMark.isEmpty {
                    Text(trailingMark)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Color.appAccent)
                }
                if isClosed {
                    Text(closedLabel)
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(1)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7).padding(.vertical, 2)
                        .background(Color.appClosedTag)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            if let branch, !branch.isEmpty {
                Text(branch)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appAccentD)
            }
        }
    }

    @ViewBuilder
    private var nowBox: some View {
        if let nowNumber {
            VStack(spacing: 2) {
                Text("目前看到")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(Color.appAccentD)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(nowNumber)")
                        .font(.system(size: 30, weight: .heavy))
                        .tracking(-1.5)
                        .foregroundStyle(Color.appAccent)
                        .monospacedDigit()
                    Text("號")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(Color.appAccentD)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6).padding(.horizontal, 8)
            .background(Color.appAccentS)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appAccent, lineWidth: 2)
            )
        } else if let nowEmptyText {
            Text(nowEmptyText)
                .font(.system(size: 13, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(Color.appInk2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10).padding(.horizontal, 8)
                .background(Color.appClosed)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appBorder, lineWidth: 1.5)
                )
        }
    }
}

// MARK: - 大號碼顯示框（追蹤頁的目前號碼）

struct SimpleNowNumberBox: View {
    let label: String
    let value: String
    var color: Color = .appAccent
    var darkColor: Color = .appAccentD

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(darkColor)
            Text(value)
                .font(.system(size: 40, weight: .heavy))
                .tracking(-1.5)
                .foregroundStyle(color)
                .monospacedDigit()
        }
        .padding(.vertical, 10).padding(.horizontal, 14)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color, lineWidth: 2)
        )
    }
}

// MARK: - Live dot（脈動小綠點）

struct SimpleLiveDot: View {
    var color: Color = .appOk
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(color.opacity(pulse ? 0 : 0.55), lineWidth: pulse ? 10 : 0)
                    .frame(width: 10, height: 10)
            )
            .onAppear {
                withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                    pulse = true
                }
            }
    }
}

// MARK: - 通用容器（暖底全頁 + 固定上下、中間捲動）

struct SimpleScreen<Top: View, Content: View>: View {
    @ViewBuilder var top: () -> Top
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    top()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 6)
                .background(Color.appBg)

                ScrollView { content().padding(.horizontal, 16).padding(.bottom, 24) }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Hospital region helper

extension Hospital {
    var simpleRegion: SimpleRegion {
        SimpleRegion.of(HospitalArea.classify(self))
    }
}

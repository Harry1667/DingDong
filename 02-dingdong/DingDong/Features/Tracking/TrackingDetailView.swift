import SwiftUI

/// 點追蹤卡進來看的單一追蹤完整頁
/// 對應 /simple/tracking.html
struct TrackingDetailView: View {
    let taskId: UUID
    @EnvironmentObject var trackingService: TrackingService
    @EnvironmentObject private var favoriteService: FavoriteService
    @Environment(\.dismiss) private var dismiss
    @State private var showStopSheet: TrackingTask?

    private var task: TrackingTask? {
        trackingService.tasks.first(where: { $0.id == taskId })
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            if let task {
                ScrollView {
                    VStack(spacing: 14) {
                        infoHero(task)
                        statsRow(task)
                        progressCard(task)
                        ctaButton(task)
                        actionsRow(task)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            } else {
                VStack(spacing: 16) {
                    Text("⏳").font(.system(size: 56))
                    Text("追蹤已結束")
                        .font(.system(size: 22, weight: .heavy))
                    SimpleSecondaryButton(title: "返回") { dismiss() }
                        .padding(.horizontal, 60)
                }
                .padding()
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            topBar
        }
        .navigationBarHidden(true)
        .sheet(item: $showStopSheet) { task in
            StopFeedbackSheet(task: task) { reason in
                trackingService.stopTracking(taskId: task.id, reason: reason)
                dismiss()
            }
        }
    }

    // MARK: ── Top bar ────────────────────────────────────────

    private var topBar: some View {
        HStack {
            SimpleBackButton(action: { dismiss() })
            Spacer()
            Text("叮咚到號")
                .font(.system(size: 18, weight: .heavy))
                .tracking(1)
                .foregroundStyle(Color.appInk)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.appBg)
        .overlay(
            Rectangle()
                .fill(Color.appBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: ── Info hero ─────────────────────────────────────

    private func infoHero(_ task: TrackingTask) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(task.hospitalName)
                    .font(.system(size: 24, weight: .heavy))
                    .tracking(-0.5)
                    .foregroundStyle(Color.appInk)
                Text(task.department)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appInkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 6)
            .overlay(
                Rectangle()
                    .fill(Color.appBorder)
                    .frame(width: 1),
                alignment: .trailing
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(task.doctorName.isEmpty ? "—" : task.doctorName)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(Color.appInk)
                    Text("醫師")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.appInk2)
                }
                if !task.clinicRoom.isEmpty {
                    Text(task.clinicRoom)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(Color.appAccentD)
                        .padding(.horizontal, 12).padding(.vertical, 4)
                        .background(Color.appAccentS)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .simpleCard(radius: 18, shadowDepth: 3)
    }

    // MARK: ── Stats ────────────────────────────────────────

    private func statsRow(_ task: TrackingTask) -> some View {
        HStack(spacing: 12) {
            statBox(
                label: "目前號碼",
                value: "\(task.currentNumber)",
                unit: "號",
                sub: " ",
                tone: .accent
            )
            .frame(maxWidth: .infinity)

            let rem = remaining(task)
            statBox(
                label: rem == nil ? "您的號碼" : "您前面還有",
                value: rem.map { String(max(0, $0)) } ?? task.userNumber.map(String.init) ?? "—",
                unit: rem == nil ? "號" : (rem ?? 0) > 0 ? "人" : "",
                sub: subText(task),
                tone: passedTone(task)
            )
            .frame(maxWidth: .infinity)
        }
    }

    private enum StatTone { case accent, danger, ok }

    private func statBox(label: String, value: String, unit: String, sub: String, tone: StatTone) -> some View {
        let color: Color = {
            switch tone {
            case .accent: return .appAccent
            case .danger: return .appDanger
            case .ok:     return Color(hex: "#04A256")
            }
        }()
        let darkColor: Color = {
            switch tone {
            case .accent: return .appAccentD
            case .danger: return .appDangerD
            case .ok:     return .appOkD2
            }
        }()
        return VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.appInk2)
                .tracking(0.5)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 50, weight: .heavy))
                    .tracking(-2)
                    .foregroundStyle(color)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: value)
                Text(unit)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(darkColor)
            }
            .frame(height: 56)
            Text(sub)
                .font(.system(size: 12))
                .foregroundStyle(Color.appInk3)
                .frame(minHeight: 16)
        }
        .padding(.vertical, 16).padding(.horizontal, 14)
        .simpleCard(radius: 18, borderColor: Color.appBorder2, shadowDepth: 3)
    }

    // MARK: ── Progress ─────────────────────────────────────

    private func progressCard(_ task: TrackingTask) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("看診進度")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(Color.appInk)

            progressSteps(task)

            Divider()
                .overlay(Color.appBorder)
                .padding(.top, 6)

            Text(etaText(task))
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(Color.appInk)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 6)

            HStack(spacing: 8) {
                Text("最後更新")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appInk3)
                Text(task.lastUpdated.relativeString)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.appInkSoft)
                Spacer()
                Button {
                    Task { await trackingService.refreshAllTasks() }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .heavy))
                        Text("更新")
                            .font(.system(size: 13, weight: .heavy))
                    }
                    .foregroundStyle(Color.appAccentD)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.appAccentS)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 2)
        }
        .padding(18)
        .simpleCard(radius: 20, borderColor: Color.appBorder2, shadowDepth: 2)
    }

    private func progressSteps(_ task: TrackingTask) -> some View {
        let active = currentStepIndex(task)
        let steps: [(key: StepKind, label: String, system: String)] = [
            (.registered, "已登錄", "checkmark"),
            (.seeing,     "看診中", "person.fill"),
            (.near,       "快到您", "bell.fill"),
            (.passed,     "已過號", "exclamationmark.triangle.fill")
        ]
        let fill = CGFloat(min(max(active, 0), 3)) / 3.0
        return VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.appBorder)
                            .frame(height: 5)
                            .padding(.horizontal, geo.size.width * 0.10)
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: active == 3
                                        ? [Color.appAccent, Color.appDanger]
                                        : [Color.appAccentD, Color.appAccent],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, (geo.size.width * 0.80) * fill), height: 5)
                            .offset(x: geo.size.width * 0.10)
                            .animation(.spring(response: 0.6, dampingFraction: 0.85), value: fill)
                    }
                }
                .frame(height: 5)
                .offset(y: 22)

                HStack(spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { idx, s in
                        progressStepIcon(
                            label: s.label,
                            system: s.system,
                            state: stepState(idx: idx, active: active)
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }

    private enum StepKind { case registered, seeing, near, passed }
    private enum StepDisplayState { case pending, done, active, passed }

    private func stepState(idx: Int, active: Int) -> StepDisplayState {
        if active == 3 && idx == 3 { return .passed }
        if idx < active { return .done }
        if idx == active { return .active }
        return .pending
    }

    private func progressStepIcon(label: String, system: String, state: StepDisplayState) -> some View {
        let size: CGFloat = state == .active ? 52 : 44
        let (bg, border, fg): (Color, Color, Color) = {
            switch state {
            case .pending: return (Color.appCard, Color.appBorder, Color.appInk3)
            case .done:    return (Color.appAccentS, Color.appAccent, Color.appAccentD)
            case .active:  return (Color.appAccent, Color.appAccent, .white)
            case .passed:  return (Color.appDangerS, Color.appDanger, Color.appDangerD)
            }
        }()
        return VStack(spacing: 6) {
            ZStack {
                Circle().fill(bg)
                Circle().stroke(border, lineWidth: 3)
                Image(systemName: system)
                    .font(.system(size: state == .active ? 22 : 18, weight: .heavy))
                    .foregroundStyle(fg)
            }
            .frame(width: size, height: size)
            .shadow(
                color: state == .active ? Color.appAccent.opacity(0.35) : .clear,
                radius: 14, x: 0, y: 6
            )
            .overlay(
                Circle()
                    .stroke(state == .active ? Color.appAccentR : .clear, lineWidth: 6)
                    .scaleEffect(state == .active ? 1.18 : 1)
                    .opacity(state == .active ? 1 : 0)
            )
            .offset(y: state == .active ? -4 : 0)

            Text(label)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(state == .pending ? Color.appInk2 :
                                 state == .passed ? Color.appDangerD : Color.appAccentD)
                .tracking(0.5)
        }
    }

    // MARK: ── CTA ──────────────────────────────────────────

    private func ctaButton(_ task: TrackingTask) -> some View {
        let state = currentStepIndex(task)
        let isPassed = state == 3
        let isYours = task.userNumber.map { task.currentNumber == $0 } ?? false
        let isNear = state == 2

        let (title, sub, gradient, shadow, icon): (String, String, [Color], Color, String) = {
            if isPassed {
                return ("已過號", "您的號碼已經過了",
                        [Color.appDanger, Color.appDangerD],
                        Color(hex: "#7A2121"),
                        "exclamationmark.triangle.fill")
            }
            if isYours {
                return ("輪到您了", "請準備就緒",
                        [Color.appAccent, Color.appAccentD],
                        Color.appAccentDD,
                        "bell.fill")
            }
            if isNear {
                return ("快到您了", "請就近準備",
                        [Color.appAccent, Color.appAccentD],
                        Color.appAccentDD,
                        "bell.fill")
            }
            return ("等候中", "請您稍候看診進度",
                    [Color(hex: "#F2EEE1"), Color(hex: "#E3DCC6")],
                    Color(hex: "#C9BFA3"),
                    "clock")
        }()
        let isWaiting = !isPassed && !isYours && !isNear

        return Button {
            Task { await trackingService.refreshAllTasks() }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(isWaiting
                        ? Color.appInk.opacity(0.08) : Color.white.opacity(0.22))
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(isWaiting ? Color.appInkSoft : .white)
                }
                .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 22, weight: .heavy))
                        .tracking(1)
                    Text(sub)
                        .font(.system(size: 13, weight: .semibold))
                        .opacity(0.93)
                }
                .foregroundStyle(isWaiting ? Color.appInkSoft : .white)
                Spacer()
            }
            .padding(.horizontal, 18).padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(colors: gradient,
                                       startPoint: .top, endPoint: .bottom))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: shadow, radius: 0, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: ── Actions ──────────────────────────────────────

    private func actionsRow(_ task: TrackingTask) -> some View {
        HStack(spacing: 10) {
            NavigationLink(destination: HospitalListView()) {
                Text("追加其他")
                    .font(.system(size: 17, weight: .heavy))
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .foregroundStyle(Color.appInk)
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.appBorder, lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)

            Button {
                showStopSheet = task
            } label: {
                Text("停止追蹤")
                    .font(.system(size: 17, weight: .heavy))
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .foregroundStyle(Color.appDangerD)
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "#F2C6C6"), lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: ── Helpers ──────────────────────────────────────

    private func remaining(_ task: TrackingTask) -> Int? {
        guard let u = task.userNumber else { return nil }
        return u - task.currentNumber
    }

    private func subText(_ task: TrackingTask) -> String {
        guard let u = task.userNumber else { return " " }
        return "您是第 \(u) 號"
    }

    private func passedTone(_ task: TrackingTask) -> StatTone {
        guard let u = task.userNumber else { return .accent }
        if task.currentNumber > u { return .danger }
        if task.currentNumber == u { return .ok }
        return .accent
    }

    private func etaText(_ task: TrackingTask) -> String {
        if let u = task.userNumber {
            if task.currentNumber > u { return "您的號碼已經過了" }
            if task.currentNumber == u { return "輪到您了，請盡快至診間" }
            if let mins = task.estimatedMinutes {
                return "預估還需 \(mins) 分鐘輪到您"
            }
            return "還差 \(u - task.currentNumber) 號輪到您"
        }
        return "等候醫院資料中…"
    }

    /// 0=registered, 1=seeing, 2=near, 3=passed
    private func currentStepIndex(_ task: TrackingTask) -> Int {
        guard task.userNumber != nil else {
            return task.currentNumber > 0 ? 1 : 0
        }
        let rem = remaining(task) ?? 0
        if rem < 0 { return 3 }      // passed
        if rem <= 3 { return 2 }     // near
        if task.currentNumber > 0 { return 1 } // seeing
        return 0                     // registered
    }
}

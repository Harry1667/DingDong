import SwiftUI

struct HomeView: View {
    @EnvironmentObject var trackingService: TrackingService
    @EnvironmentObject var notificationService: NotificationService
    @StateObject private var vm: HomeViewModel
    @Environment(\.scenePhase) private var scenePhase

    @State private var glowPulse = false
    @State private var feedbackTask: TrackingTask?
    @State private var highlightedTaskId: UUID?

    init() {
        _vm = StateObject(wrappedValue: HomeViewModel(trackingService: TrackingService.shared))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ambientBackground
                Group {
                    if vm.tasks.isEmpty {
                        emptyState
                    } else {
                        taskList
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image("AppIconNav")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("叮咚到號")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.appGreen)
                    }
                }
                if !vm.tasks.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task { await trackingService.refreshAllTasks() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(Color.appGreen)
                        }
                    }
                }
            }
        }
        .sheet(item: $feedbackTask) { task in
            StopFeedbackSheet(task: task) { reason in
                trackingService.stopTracking(taskId: task.id, reason: reason)
            }
        }
        .task {
            await notificationService.checkAuthorizationStatus()
            if !notificationService.isAuthorized {
                await notificationService.requestAuthorization()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                BackgroundService.shared.scheduleNextRefresh()
            }
        }
    }

    // MARK: - Task list

    private var taskList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    let active = vm.tasks.filter { $0.status == .active }
                    if !active.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(active) { task in
                                TrackingCardView(task: task, onStop: { feedbackTask = task },
                                                 isHighlighted: highlightedTaskId == task.id)
                                    .id(task.id)
                            }
                        }
                    }

                    let scheduled = vm.tasks.filter { $0.status == .scheduled }
                    if !scheduled.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("預約中")
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Color.appTextSecondary)
                                .padding(.horizontal, 4)
                            ForEach(scheduled) { task in
                                scheduledCard(task: task)
                            }
                        }
                    }

                    if vm.tasks.count < TrackingService.maxTasks {
                        addButton
                    }

                    historySection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .refreshable { await trackingService.refreshAllTasks() }
            .onChange(of: notificationService.pendingDeepLinkTaskId) { dbId in
                handleDeepLink(dbId: dbId, proxy: proxy)
            }
            .onAppear {
                handleDeepLink(dbId: notificationService.pendingDeepLinkTaskId, proxy: proxy)
            }
        }
    }

    private func handleDeepLink(dbId: Int?, proxy: ScrollViewProxy) {
        guard let dbId else { return }
        guard let task = trackingService.tasks.first(where: { $0.dbId == dbId }) else { return }
        notificationService.pendingDeepLinkTaskId = nil
        highlightedTaskId = task.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation { proxy.scrollTo(task.id, anchor: .center) }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            highlightedTaskId = nil
        }
    }

    // MARK: - History

    @ViewBuilder
    private var historySection: some View {
        let history = PersistenceService.shared.trackingHistory.suffix(5).reversed() as [TrackingRecord]
        if !history.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("最近紀錄")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.horizontal, 4)
                ForEach(history) { record in
                    historyCard(record)
                }
            }
        }
    }

    private func historyCard(_ record: TrackingRecord) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(record.doctorName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("\(record.hospitalName) · \(record.clinicRoom)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(historyReasonLabel(record.endReason))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(historyReasonColor(record.endReason))
                Text(record.date, style: .date)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.7))
            }
        }
        .padding(12)
        .background(Color.appSurface.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.appBorder, lineWidth: 1))
    }

    private func historyReasonLabel(_ reason: String) -> String {
        switch reason {
        case "notified":  return "已叫號"
        case "finished":  return "診已結束"
        case "skipped":   return "已過號"
        default:          return "已取消"
        }
    }

    private func historyReasonColor(_ reason: String) -> Color {
        switch reason {
        case "notified": return Color.appGreen
        case "finished": return Color.appTextSecondary
        case "skipped":  return Color.appUrgency
        default:         return Color.appTextSecondary.opacity(0.6)
        }
    }

    // MARK: - Scheduled card

    private func scheduledCard(task: TrackingTask) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.doctorName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("\(task.hospitalName) · \(task.clinicRoom)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                if let date = task.scheduledDate {
                    Text(date, style: .date)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.appGreen)
                }
                Text("等待開診")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary)
            }
            Button {
                trackingService.stopTracking(taskId: task.id, reason: "cancelled")
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.appTextSecondary.opacity(0.4))
                    .font(.system(size: 18))
            }
        }
        .padding(14)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBorder, lineWidth: 1))
    }

    private var addButton: some View {
        NavigationLink(destination: HospitalListView()) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                Text("新增追蹤")
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.appGreenLight)
            .foregroundStyle(Color.appGreen)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 16) {
                Text("—")
                    .font(.system(size: 72, weight: .bold, design: .serif))
                    .foregroundStyle(Color.appGreen.opacity(0.25))
                VStack(spacing: 8) {
                    Text("尚未追蹤任何醫師")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("選擇醫院，輸入掛號號碼\n輪到您時立即通知")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            NavigationLink(destination: HospitalListView()) {
                HStack(spacing: 8) {
                    Image(systemName: "cross.case.fill")
                    Text("選擇醫院")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.appGreen)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 40)
            Spacer()
        }
        .padding()
    }

    // MARK: - Ambient background

    private var ambientBackground: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(Color.appGreen.opacity(0.04))
                    .frame(width: geo.size.width * 0.75)
                    .blur(radius: 80)
                    .offset(x: -geo.size.width * 0.25, y: -geo.size.height * 0.05)
                    .scaleEffect(glowPulse ? 1.08 : 0.92)
                Circle()
                    .fill(Color.appGreenMid.opacity(0.03))
                    .frame(width: geo.size.width * 0.6)
                    .blur(radius: 70)
                    .offset(x: geo.size.width * 0.35, y: geo.size.height * 0.55)
                    .scaleEffect(glowPulse ? 0.92 : 1.08)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

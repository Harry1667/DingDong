import SwiftUI

struct HomeView: View {
    @EnvironmentObject var trackingService: TrackingService
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject private var favoriteService: FavoriteService
    @StateObject private var vm: HomeViewModel
    @Environment(\.scenePhase) private var scenePhase

    @State private var glowPulse        = false
    @State private var feedbackTask: TrackingTask?
    @State private var highlightedTaskId: UUID?
    @State private var quickTrackItem: QuickTrackItem?
    @State private var loadingFavoriteId: UUID?
    @State private var noDataDoctorName: String?
    @State private var showAddFavorite  = false

    init() {
        _vm = StateObject(wrappedValue: HomeViewModel(trackingService: TrackingService.shared))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                ambientGlow
                mainScroll
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { navBar }
        }
        .sheet(item: $feedbackTask) { task in
            StopFeedbackSheet(task: task) { reason in
                trackingService.stopTracking(taskId: task.id, reason: reason)
            }
        }
        .sheet(item: $quickTrackItem) { item in
            TrackingSetupView(hospital: item.hospital, progress: item.progress)
        }
        .sheet(isPresented: $showAddFavorite) {
            AddFavoriteBrowserSheet().environmentObject(favoriteService)
        }
        .alert("今日無出診資料", isPresented: Binding(
            get: { noDataDoctorName != nil },
            set: { if !$0 { noDataDoctorName = nil } }
        )) {
            Button("確定", role: .cancel) {}
        } message: {
            Text("\(noDataDoctorName ?? "") 今日無看診資料，請明日再試")
        }
        .task {
            await notificationService.checkAuthorizationStatus()
            if !notificationService.isAuthorized {
                await notificationService.requestAuthorization()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                Task { await trackingService.refreshAllTasks() }
            case .background:
                BackgroundService.shared.scheduleNextRefresh()
            default:
                break
            }
        }
    }

    // MARK: ── Navigation bar ─────────────────────────────────

    @ToolbarContentBuilder
    private var navBar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 8) {
                Image("AppIconNav")
                    .resizable().scaledToFit()
                    .frame(width: 26, height: 26)
                Text("叮咚到號")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
        }
        if !vm.tasks.isEmpty {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await trackingService.refreshAllTasks() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.appGreen)
                }
            }
        }
    }

    // MARK: ── Main scroll ────────────────────────────────────

    private var mainScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    // 追蹤中
                    trackingSection
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 32)

                    sectionDivider

                    // 常用醫師
                    favoritesSection
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                        .padding(.bottom, 44)
                }
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

    private var sectionDivider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.appBorder)
                .frame(height: 1)
        }
        .padding(.horizontal, 20)
    }

    // MARK: ── 追蹤中 ─────────────────────────────────────────

    private var trackingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            let active    = vm.tasks.filter { $0.status == .active }
            let scheduled = vm.tasks.filter { $0.status == .scheduled }
            let total     = active.count + scheduled.count

            // Section header
            HStack(alignment: .center) {
                Label {
                    Text("追蹤中")
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(1.5)
                } icon: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 10))
                }
                .foregroundStyle(Color.appTextSecondary)

                if total > 0 {
                    Text("\(total)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.appGreen.opacity(0.12))
                        .foregroundStyle(Color.appGreen)
                        .clipShape(Capsule())
                }
            }

            // Content
            if active.isEmpty && scheduled.isEmpty {
                trackingEmptyState
            } else {
                VStack(spacing: 14) {
                    ForEach(active) { task in
                        TrackingCardView(
                            task: task,
                            onStop: { feedbackTask = task },
                            isHighlighted: highlightedTaskId == task.id
                        )
                        .id(task.id)
                    }
                }

                if !scheduled.isEmpty {
                    if !active.isEmpty {
                        sectionSubheader("預約中", icon: "clock")
                            .padding(.top, 6)
                    }
                    VStack(spacing: 10) {
                        ForEach(scheduled) { task in
                            scheduledCard(task)
                        }
                    }
                }

                if vm.tasks.count < TrackingService.maxTasks {
                    addTrackingButton
                        .padding(.top, 4)
                }
            }
        }
    }

    private var trackingEmptyState: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Image(systemName: "bell.slash")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.appGreen.opacity(0.25))
                Text("目前無追蹤任務")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)
                Text("選擇醫院與掛號號碼，輪到您時立即通知")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)

            addTrackingButton
        }
    }

    private var addTrackingButton: some View {
        NavigationLink(destination: HospitalListView()) {
            HStack(spacing: 7) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 15))
                Text("新增追蹤")
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color.appGreenLight)
            .foregroundStyle(Color.appGreen)
            .clipShape(RoundedRectangle(cornerRadius: 14))
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            highlightedTaskId = nil
        }
    }

    // MARK: ── 常用醫師 ────────────────────────────────────────

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section header + add button
            HStack(alignment: .center) {
                Label {
                    Text("常用醫師")
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(1.5)
                } icon: {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                }
                .foregroundStyle(Color.appTextSecondary)

                if !favoriteService.favorites.isEmpty {
                    Text("\(favoriteService.favorites.count)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.appGreen.opacity(0.12))
                        .foregroundStyle(Color.appGreen)
                        .clipShape(Capsule())
                }

                Spacer()

                Button { showAddFavorite = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                        Text("新增")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.appGreenLight)
                    .foregroundStyle(Color.appGreen)
                    .clipShape(Capsule())
                }
            }

            // Content
            if favoriteService.favorites.isEmpty {
                favoritesEmptyState
            } else {
                VStack(spacing: 10) {
                    ForEach(favoriteService.favorites) { fav in
                        favoriteCard(fav)
                    }
                }
            }
        }
    }

    private var favoritesEmptyState: some View {
        Button { showAddFavorite = true } label: {
            HStack(spacing: 14) {
                Image(systemName: "star.circle")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.appGreen.opacity(0.40))

                VStack(alignment: .leading, spacing: 3) {
                    Text("加入常用醫師")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("下次直接快速追蹤，省去三層選擇")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.7))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.appGreen.opacity(0.5))
            }
            .padding(16)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        Color.appGreen.opacity(0.20),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
            )
        }
    }

    private func favoriteCard(_ fav: FavoriteDoctor) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(fav.doctorName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("\(fav.hospitalName)  ·  \(fav.clinicRoom)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
            Button { Task { await quickTrack(fav) } } label: {
                Group {
                    if loadingFavoriteId == fav.id {
                        ProgressView().tint(Color.appGreen)
                    } else {
                        Text("快速追蹤")
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .frame(width: 64, height: 16)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Color.appGreenLight)
                .foregroundStyle(Color.appGreen)
                .clipShape(Capsule())
            }
            .disabled(loadingFavoriteId == fav.id)
            Button { favoriteService.remove(fav) } label: {
                Image(systemName: "star.slash")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.30))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBorder, lineWidth: 1))
    }

    private func quickTrack(_ fav: FavoriteDoctor) async {
        loadingFavoriteId = fav.id
        defer { loadingFavoriteId = nil }
        guard let response = try? await HospitalService.shared.fetchProgress(hospitalCode: fav.hospitalCode) else {
            noDataDoctorName = fav.doctorName
            return
        }
        guard let match = response.data.first(where: {
            $0.doctorName == fav.doctorName && $0.clinicRoom == fav.clinicRoom
        }) else {
            noDataDoctorName = fav.doctorName
            return
        }
        quickTrackItem = QuickTrackItem(
            hospital: Hospital(code: fav.hospitalCode, name: fav.hospitalName),
            progress: match
        )
    }

    // MARK: ── Scheduled card ─────────────────────────────────

    private func scheduledCard(_ task: TrackingTask) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.doctorName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("\(task.hospitalName)  ·  \(task.clinicRoom)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                if let date = task.scheduledDate {
                    Text(date, style: .date)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.appGreen)
                }
                Text("等待開診")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color.appTextSecondary)
            }

            let isFav = favoriteService.isFavorite(
                hospitalCode: task.hospitalCode,
                doctorName: task.doctorName,
                clinicRoom: task.clinicRoom
            )
            Button {
                favoriteService.toggle(
                    hospitalCode: task.hospitalCode, hospitalName: task.hospitalName,
                    department: task.department, doctorName: task.doctorName,
                    clinicRoom: task.clinicRoom
                )
            } label: {
                Image(systemName: isFav ? "star.fill" : "star")
                    .font(.system(size: 15))
                    .foregroundStyle(isFav ? Color.appGreen : Color.appTextSecondary.opacity(0.30))
            }

            Button {
                trackingService.stopTracking(taskId: task.id, reason: "cancelled")
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.30))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBorder, lineWidth: 1))
    }

    // MARK: ── Helpers ─────────────────────────────────────────

    private func sectionSubheader(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundStyle(Color.appTextSecondary.opacity(0.7))
    }

    // MARK: ── Ambient glow ────────────────────────────────────

    private var ambientGlow: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(Color.appGreen.opacity(0.04))
                    .frame(width: geo.size.width * 0.8)
                    .blur(radius: 90)
                    .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.08)
                    .scaleEffect(glowPulse ? 1.10 : 0.90)
                Circle()
                    .fill(Color.appGreenMid.opacity(0.03))
                    .frame(width: geo.size.width * 0.65)
                    .blur(radius: 80)
                    .offset(x: geo.size.width * 0.35, y: geo.size.height * 0.55)
                    .scaleEffect(glowPulse ? 0.90 : 1.10)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct QuickTrackItem: Identifiable {
    let id = UUID()
    let hospital: Hospital
    let progress: ClinicProgress
}

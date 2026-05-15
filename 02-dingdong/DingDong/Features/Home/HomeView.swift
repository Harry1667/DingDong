import SwiftUI

struct HomeView: View {
    @EnvironmentObject var trackingService: TrackingService
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject private var favoriteService: FavoriteService
    @StateObject private var vm: HomeViewModel
    @Environment(\.scenePhase) private var scenePhase

    @State private var feedbackTask: TrackingTask?
    @State private var highlightedTaskId: UUID?
    @State private var quickTrackItem: QuickTrackItem?
    @State private var loadingFavoriteId: UUID?
    @State private var noDataDoctorName: String?
    @State private var showAddFavorite = false
    @State private var showPaywall = false
    @State private var path = NavigationPath()   // push TrackingDetailView (UUID) / HospitalListView (String)

    /// 達追蹤上限時是否該跳 paywall（免費版且 active+scheduled tasks 已滿）
    private var shouldShowPaywallForNewTracking: Bool {
        let tier = PersistenceService.shared.userTier
        let count = trackingService.tasks.filter { !$0.isFinished }.count
        return tier == .free && count >= tier.trackLimit
    }

    private func attemptAddTracking() {
        if shouldShowPaywallForNewTracking {
            showPaywall = true
        } else {
            path.append("addTracking")
        }
    }

    init() {
        _vm = StateObject(wrappedValue: HomeViewModel(trackingService: TrackingService.shared))
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.appBg.ignoresSafeArea()
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 14) {
                            header
                            trackingSection
                            favoritesSection
                                .padding(.top, 6)
                        }
                        .padding(.horizontal, 16)
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
            .navigationBarHidden(true)
            .navigationDestination(for: UUID.self) { taskId in
                TrackingDetailView(taskId: taskId)
            }
            .navigationDestination(for: String.self) { route in
                if route == "addTracking" {
                    HospitalListView()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didStartNewTracking)) { note in
            guard let taskId = note.userInfo?["taskId"] as? UUID else { return }
            // 等其他 sheet（TrackingSetupView）dismiss 完再 push；先清掉 HospitalListView 路徑
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                path = NavigationPath()
                path.append(taskId)
            }
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
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
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                Task { await trackingService.refreshAllTasks() }
            case .background:
                BackgroundService.shared.scheduleNextRefresh()
            default: break
            }
        }
    }

    // MARK: ── Header ─────────────────────────────────────────

    private var header: some View {
        HStack {
            HStack(spacing: 10) {
                Image("AppIconNav")
                    .resizable().scaledToFit()
                    .frame(width: 30, height: 30)
                Text("叮咚到號")
                    .font(.system(size: 20, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(Color.appInk)
            }
            Spacer()
            if !vm.tasks.isEmpty {
                Button {
                    Task { await trackingService.refreshAllTasks() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Color.appAccentD)
                        .frame(width: 40, height: 40)
                        .background(Color.appAccentS)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.appAccent, lineWidth: 2))
                }
            }
        }
    }

    // MARK: ── 追蹤中 ─────────────────────────────────────────

    private var trackingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let active    = vm.tasks.filter { $0.status == .active }
            let scheduled = vm.tasks.filter { $0.status == .scheduled }
            let total     = active.count + scheduled.count

            HStack(spacing: 8) {
                Text("我的追蹤")
                    .font(.system(size: 22, weight: .heavy))
                    .tracking(-0.3)
                    .foregroundStyle(Color.appInk)
                if total > 0 {
                    Text("\(total) / \(TrackingService.maxTasks)")
                        .font(.system(size: 13, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Color.appAccentD)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.appAccentS)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.appAccent, lineWidth: 1.5))
                }
                Spacer()
            }

            if active.isEmpty && scheduled.isEmpty {
                addTrackingCTA(isFirst: true)
            } else {
                VStack(spacing: 10) {
                    ForEach(active) { task in
                        NavigationLink(destination: TrackingDetailView(taskId: task.id)) {
                            TrackingCardView(
                                task: task,
                                onStop: { feedbackTask = task },
                                isHighlighted: highlightedTaskId == task.id
                            )
                        }
                        .buttonStyle(.plain)
                        .id(task.id)
                    }
                    ForEach(scheduled) { task in
                        scheduledCard(task)
                    }
                }
                // 「再追一位」永遠顯示；按下若已達上限會跳 paywall
                addTrackingCTA(isFirst: false)
                    .padding(.top, 4)
            }
        }
    }

    private func addTrackingCTA(isFirst: Bool) -> some View {
        Button { attemptAddTracking() } label: {
            HStack(spacing: 14) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 26, weight: .heavy))
                VStack(alignment: .leading, spacing: 2) {
                    Text(isFirst ? "新增追蹤" : "再追一位")
                        .font(.system(size: 20, weight: .heavy))
                        .tracking(1)
                    Text("選擇醫院、科別與醫師")
                        .font(.system(size: 13, weight: .semibold))
                        .opacity(0.92)
                }
                Spacer()
            }
            .padding(.horizontal, 18).padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [Color.appAccent, Color.appAccentD],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.appAccentDD.opacity(0.95), radius: 0, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private func scheduledCard(_ task: TrackingTask) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(task.doctorName)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Color.appInk)
                Text("\(task.hospitalName) · \(task.clinicRoom)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appInkSoft)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                if let date = task.scheduledDate {
                    Text(date, style: .date)
                        .font(.system(size: 13, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Color.appAccentD)
                }
                Text("等待開診")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.appInkSoft)
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
                    .font(.system(size: 17))
                    .foregroundStyle(isFav ? Color.appAccent : Color.appInk3)
            }
            Button {
                trackingService.stopTracking(taskId: task.id, reason: "cancelled")
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.appInk3.opacity(0.5))
            }
        }
        .padding(14)
        .simpleCard(radius: 16)
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

    // MARK: ── 常用醫師 ──────────────────────────────────────

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("常用醫師")
                    .font(.system(size: 20, weight: .heavy))
                    .tracking(-0.3)
                    .foregroundStyle(Color.appInk)
                if !favoriteService.favorites.isEmpty {
                    Text("\(favoriteService.favorites.count)")
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Color.appAccentD)
                        .padding(.horizontal, 7).padding(.vertical, 2)
                        .background(Color.appAccentS)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.appAccent, lineWidth: 1.5))
                }
                Spacer()
                Button { showAddFavorite = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus").font(.system(size: 12, weight: .heavy))
                        Text("新增").font(.system(size: 13, weight: .heavy))
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .foregroundStyle(.white)
                    .background(Color.appInk)
                    .clipShape(Capsule())
                }
            }

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
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.appAccent.opacity(0.55))
                VStack(alignment: .leading, spacing: 2) {
                    Text("加入常用醫師")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(Color.appInk)
                    Text("下次直接快速追蹤，省去三層選擇")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appInkSoft)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Color.appAccentD.opacity(0.6))
            }
            .padding(16)
            .background(Color.appCardWarm)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        Color.appAccent.opacity(0.55),
                        style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func favoriteCard(_ fav: FavoriteDoctor) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(fav.doctorName)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Color.appInk)
                Text("\(fav.hospitalName) · \(fav.clinicRoom)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appInkSoft)
            }
            Spacer()
            Button { Task { await quickTrack(fav) } } label: {
                Group {
                    if loadingFavoriteId == fav.id {
                        ProgressView().tint(.white)
                    } else {
                        Text("快速追蹤")
                            .font(.system(size: 13, weight: .heavy))
                    }
                }
                .frame(width: 72, height: 36)
                .foregroundStyle(.white)
                .background(Color.appAccent)
                .clipShape(Capsule())
                .shadow(color: Color.appAccentD, radius: 0, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .disabled(loadingFavoriteId == fav.id)
            Button { favoriteService.remove(fav) } label: {
                Image(systemName: "star.slash")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appInk3.opacity(0.5))
            }
        }
        .padding(14)
        .simpleCard(radius: 16)
    }

    private func quickTrack(_ fav: FavoriteDoctor) async {
        if shouldShowPaywallForNewTracking {
            showPaywall = true
            return
        }
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
}

private struct QuickTrackItem: Identifiable {
    let id = UUID()
    let hospital: Hospital
    let progress: ClinicProgress
}

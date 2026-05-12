import SwiftUI

struct HomeView: View {
    @EnvironmentObject var trackingService: TrackingService
    @EnvironmentObject var notificationService: NotificationService
    @StateObject private var vm: HomeViewModel

    init() {
        _vm = StateObject(wrappedValue: HomeViewModel(trackingService: TrackingService.shared))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                    .opacity(breatheOpacity)
                    .animation(
                        .easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: breatheOpacity
                    )

                Group {
                    if vm.tasks.isEmpty {
                        emptyState
                    } else {
                        trackingList
                    }
                }
            }
            .navigationTitle("叮咚到號")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
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
        .task {
            await notificationService.checkAuthorizationStatus()
            if !notificationService.isAuthorized {
                await notificationService.requestAuthorization()
            }
        }
        .onAppear { breatheOpacity = 0.94 }
    }

    // Breathing background
    @State private var breatheOpacity: Double = 1.0

    private var trackingList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(vm.tasks) { task in
                    TrackingCardView(task: task) {
                        trackingService.stopTracking(taskId: task.id)
                    }
                }

                if vm.tasks.count < TrackingService.maxTasks {
                    addMoreButton
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    private var addMoreButton: some View {
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

    private var emptyState: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                // Large serif number as decorative element
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
}

#Preview("空白狀態") {
    HomeView()
        .environmentObject(TrackingService.shared)
        .environmentObject(NotificationService.shared)
}

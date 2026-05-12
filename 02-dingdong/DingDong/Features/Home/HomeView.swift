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
            Group {
                if vm.tasks.isEmpty {
                    emptyState
                } else {
                    trackingList
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
    }

    private var trackingList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(vm.tasks) { task in
                    TrackingCardView(task: task) {
                        trackingService.stopTracking(taskId: task.id)
                    }
                }

                if vm.tasks.count < TrackingService.maxTasks {
                    addMoreButton
                }
            }
            .padding()
        }
    }

    private var addMoreButton: some View {
        NavigationLink(destination: HospitalListView()) {
            Label("新增追蹤", systemImage: "plus.circle.fill")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.appGreenLight)
                .foregroundStyle(Color.appGreen)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "stethoscope.circle")
                .font(.system(size: 72))
                .foregroundStyle(Color.appGreen.opacity(0.4))

            VStack(spacing: 8) {
                Text("尚未追蹤任何醫師")
                    .font(.title3.bold())
                Text("選擇醫院，輸入掛號號碼\n輪到您時立即通知")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            NavigationLink(destination: HospitalListView()) {
                Label("選擇醫院", systemImage: "cross.case.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appGreen)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }
}

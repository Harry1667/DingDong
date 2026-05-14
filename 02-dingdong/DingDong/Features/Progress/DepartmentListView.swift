import SwiftUI

struct DepartmentListView: View {
    @StateObject private var vm: ProgressViewModel
    @Environment(\.dismiss) private var dismiss

    init(hospital: Hospital) {
        _vm = StateObject(wrappedValue: ProgressViewModel(hospital: hospital))
    }

    private var allDepartments: [String] {
        Array(Set(vm.progressData.map { $0.department })).sorted()
    }

    private var sortedDepartments: [(name: String, isClosed: Bool, picks: Int)] {
        let active = Set(allDepartments)
        return active.map { name in
            let picks = PersistenceService.shared.pickCount(
                kind: "dept",
                scope: vm.hospital.code,
                item: name
            )
            return (name: name, isClosed: false, picks: picks)
        }.sorted { lhs, rhs in
            if lhs.isClosed != rhs.isClosed { return !lhs.isClosed }
            if lhs.picks != rhs.picks { return lhs.picks > rhs.picks }
            return lhs.name < rhs.name
        }
    }

    var body: some View {
        SimpleScreen {
            SimpleTopBar(title: vm.hospital.name, onBack: { dismiss() })
            SimpleStepTitle(title: "您要看哪一科？", step: 2, total: 4)
        } content: {
            content
        }
        .task { await vm.load() }
        .refreshable { await vm.refresh() }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading && vm.progressData.isEmpty {
            VStack(spacing: 16) {
                ProgressView().tint(Color.appAccent)
                Text("載入看診資料…")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appInkSoft)
            }
            .frame(maxWidth: .infinity).padding(.top, 60)
        } else if let error = vm.errorMessage, vm.progressData.isEmpty {
            errorView(error)
        } else if allDepartments.isEmpty {
            noDataView
        } else {
            SimpleTwoColGrid {
                ForEach(sortedDepartments, id: \.name) { item in
                    let picks = item.picks
                    let star: String? = picks >= 3 ? "⭐" : (picks >= 1 ? "•" : nil)
                    NavigationLink {
                        DoctorListView(
                            hospital: vm.hospital,
                            department: item.name,
                            progressVM: vm
                        )
                        .onAppear {
                            PersistenceService.shared.bumpPick(
                                kind: "dept",
                                scope: vm.hospital.code,
                                item: item.name
                            )
                        }
                    } label: {
                        SimpleGridCard(
                            title: item.name,
                            subtitle: nil,
                            isClosed: item.isClosed,
                            trailingMark: star,
                            minHeight: 90,
                            action: {}
                        )
                        .allowsHitTesting(false)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 6)
        }
    }

    private var noDataView: some View {
        let offHours = !TrackingService.isOperatingHours()
        return VStack(spacing: 14) {
            Text(offHours ? "🌙" : "📋").font(.system(size: 48))
            Text(offHours ? "目前非看診時間" : "今日無看診資料")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(Color.appInk)
            Text(offHours
                ? "看診時間為週一至週六 07:00–21:00\n請於開診後再查詢"
                : "此醫院今日可能未開診，或資料尚未更新")
                .font(.system(size: 15))
                .foregroundStyle(Color.appInkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity).padding(.top, 40)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 14) {
            Text("⏳").font(.system(size: 48))
            Text("載入失敗")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(Color.appInk)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Color.appInkSoft)
                .multilineTextAlignment(.center)
            SimpleSecondaryButton(title: "重試") {
                Task { await vm.load() }
            }
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity).padding(.top, 40)
    }
}

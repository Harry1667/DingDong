import SwiftUI

/// 醫院選擇器：北/中/南 三 tab + 兩欄 grid（/simple 風格）。
/// 透過 `destination` 控制點選醫院後 push 到哪個 view。
struct HospitalPicker<Destination: View>: View {
    @StateObject private var vm = HospitalViewModel()
    @State private var selectedRegion: SimpleRegion = .north
    @State private var pickBumpToken: UUID = UUID()

    var title: String = "請選擇您要去的醫院"
    var stepIndex: Int? = 1
    var totalSteps: Int = 4
    var onBack: (() -> Void)? = nil
    @ViewBuilder var destination: (SimpleHospital) -> Destination

    private var expanded: [SimpleHospital] {
        SimpleHospital.expand(vm.allHospitals)
    }

    private var regionCounts: [SimpleRegion: Int] {
        var counts: [SimpleRegion: Int] = [:]
        for h in expanded {
            counts[h.simpleRegion, default: 0] += 1
        }
        return counts
    }

    private func isClosed(_ h: SimpleHospital) -> Bool {
        guard let open = vm.hospitalStatus[h.code] else { return false }
        return !open
    }

    private var hospitalsInRegion: [SimpleHospital] {
        expanded
            .filter { $0.simpleRegion == selectedRegion }
            .sorted { lhs, rhs in
                let lc = isClosed(lhs), rc = isClosed(rhs)
                if lc != rc { return !lc }   // 開診先
                let a = PersistenceService.shared.pickCount(kind: "hospital", scope: lhs.vid)
                let b = PersistenceService.shared.pickCount(kind: "hospital", scope: rhs.vid)
                if a != b { return a > b }
                return lhs.fullName < rhs.fullName
            }
    }

    var body: some View {
        SimpleScreen {
            SimpleTopBar(title: "叮咚到號", onBack: onBack)
            if let stepIndex {
                SimpleStepTitle(title: title, step: stepIndex, total: totalSteps)
                SimpleRegionTabs(selection: $selectedRegion, counts: regionCounts)
                    .padding(.top, 8)
            } else {
                Text(title)
                    .font(.system(size: 22, weight: .heavy))
                    .tracking(-0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                SimpleRegionTabs(selection: $selectedRegion, counts: regionCounts)
                    .padding(.top, 8)
            }
        } content: {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(selectedRegion.label) · 共 \(hospitalsInRegion.count) 家醫院")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appInkSoft)
                    .padding(.horizontal, 4)
                    .padding(.top, 10)

                if vm.isLoading && vm.allHospitals.isEmpty {
                    ProgressView()
                        .tint(Color.appAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else if let error = vm.errorMessage, vm.allHospitals.isEmpty {
                    errorState(error)
                } else if hospitalsInRegion.isEmpty {
                    Text("此地區暫無醫院")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.appInkSoft)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else {
                    SimpleTwoColGrid {
                        ForEach(hospitalsInRegion) { hospital in
                            hospitalCard(hospital)
                        }
                    }
                    tierStatusBar
                        .padding(.top, 14)
                }
            }
            .id(pickBumpToken)
        }
        .task { await vm.loadHospitals() }
        .sheet(isPresented: $showPaywall, onDismiss: {
            pickBumpToken = UUID()   // 訂閱狀態可能變了，重畫狀態列
        }) {
            PaywallView()
        }
    }

    @State private var showPaywall = false

    private var tierStatusBar: some View {
        let tier = PersistenceService.shared.userTier
        let active = TrackingService.shared.tasks.filter { !$0.isFinished }.count
        return HStack(spacing: 12) {
            HStack(spacing: 4) {
                Text("追蹤中")
                    .foregroundStyle(Color.appInk2)
                Text("\(active)/\(tier.trackLimit)")
                    .foregroundStyle(Color.appInk)
                    .fontWeight(.heavy)
            }
            .font(.system(size: 14, weight: .semibold))
            Spacer()
            if tier == .free {
                Button { showPaywall = true } label: {
                    Text("升級 Pro 追 3 個")
                        .font(.system(size: 13, weight: .heavy))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .foregroundStyle(.white)
                        .background(Color.appAccent)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.appAccentD, lineWidth: 1.5))
                }
                .buttonStyle(.plain)
            } else {
                Text("Pro")
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(1)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .foregroundStyle(.white)
                    .background(Color.appOk)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBorder, lineWidth: 2))
    }

    @ViewBuilder
    private func hospitalCard(_ hospital: SimpleHospital) -> some View {
        let picks = PersistenceService.shared.pickCount(kind: "hospital", scope: hospital.vid)
        let star: String? = picks >= 3 ? "⭐" : (picks >= 1 ? "•" : nil)
        let closed = isClosed(hospital)

        if closed {
            SimpleGridCard(
                title: hospital.name,
                branch: hospital.branch,
                subtitle: hospital.loc,
                isClosed: true,
                closedLabel: "休診中",
                trailingMark: star,
                minHeight: 112
            )
        } else {
            NavigationLink {
                destination(hospital)
                    .onAppear {
                        PersistenceService.shared.bumpPick(kind: "hospital", scope: hospital.vid)
                    }
            } label: {
                SimpleGridCard(
                    title: hospital.name,
                    branch: hospital.branch,
                    subtitle: hospital.loc,
                    isClosed: false,
                    trailingMark: star,
                    minHeight: 112
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 14) {
            Text("⏳").font(.system(size: 48))
            Text("無法載入醫院列表")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(Color.appInk)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Color.appInkSoft)
                .multilineTextAlignment(.center)
            SimpleSecondaryButton(title: "重試") {
                Task { await vm.reload() }
            }
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}

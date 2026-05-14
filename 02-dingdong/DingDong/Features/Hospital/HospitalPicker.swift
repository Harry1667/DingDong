import SwiftUI

/// 醫院選擇器：北/中/南 三 tab + 兩欄 grid（/simple 風格）。
/// 透過 `destination` 控制點選醫院後 push 到哪個 view。
struct HospitalPicker<Destination: View>: View {
    @StateObject private var vm = HospitalViewModel()
    @State private var selectedRegion: SimpleRegion = .north
    @State private var pickBumpToken: UUID = UUID()   // 觸發 grid 重新讀取 pickCount

    var title: String = "請選擇您要去的醫院"
    var stepIndex: Int? = 1
    var totalSteps: Int = 4
    var onBack: (() -> Void)? = nil
    @ViewBuilder var destination: (Hospital) -> Destination

    private var regionCounts: [SimpleRegion: Int] {
        var counts: [SimpleRegion: Int] = [:]
        for h in vm.allHospitals {
            counts[h.simpleRegion, default: 0] += 1
        }
        return counts
    }

    private var hospitalsInRegion: [Hospital] {
        vm.allHospitals
            .filter { $0.simpleRegion == selectedRegion }
            .sorted { lhs, rhs in
                let a = PersistenceService.shared.pickCount(kind: "hospital", scope: lhs.code)
                let b = PersistenceService.shared.pickCount(kind: "hospital", scope: rhs.code)
                if a != b { return a > b }
                return lhs.name < rhs.name
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
                }
            }
            .id(pickBumpToken)
        }
        .task { await vm.loadHospitals() }
    }

    @ViewBuilder
    private func hospitalCard(_ hospital: Hospital) -> some View {
        let picks = PersistenceService.shared.pickCount(kind: "hospital", scope: hospital.code)
        let star: String? = picks >= 3 ? "⭐" : (picks >= 1 ? "•" : nil)
        let location: String? = {
            if let c = hospital.city, let d = hospital.district { return "\(c) · \(d)" }
            if let c = hospital.city { return c }
            return nil
        }()

        NavigationLink {
            destination(hospital)
                .onAppear {
                    PersistenceService.shared.bumpPick(kind: "hospital", scope: hospital.code)
                }
        } label: {
            SimpleGridCard(
                title: hospital.name,
                branch: nil,
                subtitle: location,
                isClosed: false,
                trailingMark: star,
                minHeight: 112,
                action: {}
            )
            .allowsHitTesting(false)
        }
        .buttonStyle(.plain)
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

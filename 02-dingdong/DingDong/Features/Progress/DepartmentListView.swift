import SwiftUI

struct DepartmentListView: View {
    @StateObject private var vm: ProgressViewModel
    @Environment(\.dismiss) private var dismiss

    let simple: SimpleHospital

    init(simple: SimpleHospital) {
        self.simple = simple
        _vm = StateObject(wrappedValue: ProgressViewModel(hospital: simple.asHospital))
    }

    /// Scope 給 pickCount 用：tsgh:台北門 之類的子 scope 才不會三院區互相干擾
    private var pickScope: String {
        if let p = simple.branchPrefix, !p.isEmpty {
            return "\(simple.code):\(p)"
        }
        return simple.code
    }

    private struct DeptItem: Hashable {
        let full: String
        let display: String
    }

    private var rawDepartments: [String] {
        Array(Set(vm.progressData.map { $0.department }))
    }

    /// 對齊 /simple/dept.html：若有 branch_prefix 則過濾 + 去前綴顯示
    private var departments: [DeptItem] {
        let prefix = simple.branchPrefix ?? ""
        return rawDepartments.compactMap { name -> DeptItem? in
            if prefix.isEmpty {
                return DeptItem(full: name, display: name)
            }
            guard name.hasPrefix(prefix) else { return nil }
            let trimmed = String(name.dropFirst(prefix.count))
                .trimmingCharacters(in: .whitespaces)
            return DeptItem(full: name, display: trimmed.isEmpty ? name : trimmed)
        }
    }

    private var sortedDepartments: [DeptItem] {
        departments.sorted { lhs, rhs in
            let a = PersistenceService.shared.pickCount(kind: "dept", scope: pickScope, item: lhs.display)
            let b = PersistenceService.shared.pickCount(kind: "dept", scope: pickScope, item: rhs.display)
            if a != b { return a > b }
            return lhs.display < rhs.display
        }
    }

    var body: some View {
        SimpleScreen {
            SimpleTopBar(title: simple.fullName, onBack: { dismiss() })
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
        } else if sortedDepartments.isEmpty {
            noDataView
        } else {
            SimpleTwoColGrid {
                ForEach(sortedDepartments, id: \.self) { item in
                    let picks = PersistenceService.shared.pickCount(kind: "dept", scope: pickScope, item: item.display)
                    let star: String? = picks >= 3 ? "⭐" : (picks >= 1 ? "•" : nil)
                    NavigationLink {
                        DoctorListView(
                            hospital: simple.asHospital,
                            department: item.full,
                            departmentDisplay: item.display,
                            progressVM: vm
                        )
                        .onAppear {
                            PersistenceService.shared.bumpPick(kind: "dept", scope: pickScope, item: item.display)
                        }
                    } label: {
                        SimpleGridCard(
                            title: item.display,
                            subtitle: nil,
                            isClosed: false,
                            trailingMark: star,
                            minHeight: 90
                        )
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

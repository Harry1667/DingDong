import SwiftUI

struct HospitalListView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HospitalPicker(
            title: "請選擇您要去的醫院",
            stepIndex: 1,
            totalSteps: 4,
            onBack: { dismiss() }
        ) { hospital in
            DepartmentListView(hospital: hospital)
        }
        .onReceive(NotificationCenter.default.publisher(for: .didStartNewTracking)) { _ in
            dismiss()
        }
    }
}

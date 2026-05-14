import SwiftUI

struct HospitalListView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HospitalPicker { hospital in
            DepartmentListView(hospital: hospital)
        }
        .navigationTitle("選擇醫院")
        .onReceive(NotificationCenter.default.publisher(for: .didStartNewTracking)) { _ in
            dismiss()
        }
    }
}

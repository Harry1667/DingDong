import SwiftUI

struct DoctorListView: View {
    let hospital: Hospital
    let department: String
    let doctors: [ClinicProgress]
    @ObservedObject var progressVM: ProgressViewModel

    @State private var selectedDoctor: ClinicProgress?
    @State private var showTrackingSetup = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(progressVM.doctors(for: department)) { doctor in
                    DoctorProgressCard(progress: doctor) {
                        selectedDoctor = doctor
                        showTrackingSetup = true
                    }
                }
            }
            .padding()
        }
        .navigationTitle(department)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedDoctor) { doctor in
            TrackingSetupView(hospital: hospital, progress: doctor)
        }
        .refreshable { await progressVM.refresh() }
    }
}

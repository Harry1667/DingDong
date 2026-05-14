import SwiftUI

struct DoctorListView: View {
    let hospital: Hospital
    let department: String
    @ObservedObject var progressVM: ProgressViewModel

    @State private var selectedDoctor: ClinicProgress?
    @State private var searchText = ""

    private var filteredDoctors: [ClinicProgress] {
        let all = progressVM.doctors(for: department)
        guard !searchText.isEmpty else { return all }
        return all.filter {
            $0.doctorName.localizedCaseInsensitiveContains(searchText) ||
            $0.clinicRoom.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            if filteredDoctors.isEmpty && !searchText.isEmpty {
                noResultsView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredDoctors) { doctor in
                            DoctorProgressCard(hospital: hospital, progress: doctor) {
                                selectedDoctor = doctor
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationTitle(department)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "搜尋醫師或診間")
        .sheet(item: $selectedDoctor) { doctor in
            TrackingSetupView(hospital: hospital, progress: doctor)
        }
        .refreshable { await progressVM.refresh() }
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(Color.appTextSecondary.opacity(0.4))
            Text("找不到「\(searchText)」")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Text("試試搜尋其他醫師")
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

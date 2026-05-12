import Foundation

@MainActor
final class TrackingViewModel: ObservableObject {
    @Published var userNumberText = ""
    @Published var threshold: Int = 5
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didStartTracking = false

    let hospital: Hospital
    let progress: ClinicProgress

    init(hospital: Hospital, progress: ClinicProgress) {
        self.hospital = hospital
        self.progress = progress
        self.threshold = PersistenceService.shared.notifyThreshold
    }

    var userNumber: Int? {
        let n = Int(userNumberText) ?? 0
        return n > 0 ? n : nil
    }

    var remaining: Int? {
        guard let n = userNumber else { return nil }
        return n - progress.currentNumber
    }

    func startTracking() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await TrackingService.shared.startTracking(
                hospital: hospital,
                progress: progress,
                userNumber: userNumber,
                threshold: threshold
            )
            didStartTracking = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

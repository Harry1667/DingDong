import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var notifyThreshold: Int {
        didSet { PersistenceService.shared.notifyThreshold = notifyThreshold }
    }
    @Published var notifyMode: NotifyMode {
        didSet { PersistenceService.shared.notifyMode = notifyMode }
    }
    @Published var refreshInterval: Int {
        didSet {
            PersistenceService.shared.refreshInterval = refreshInterval
            TrackingService.shared.restartPollingTimer()
        }
    }
    @Published var hapticEnabled: Bool {
        didSet { PersistenceService.shared.hapticEnabled = hapticEnabled }
    }

    init() {
        let p = PersistenceService.shared
        notifyThreshold = p.notifyThreshold
        notifyMode      = p.notifyMode
        refreshInterval = p.refreshInterval
        hapticEnabled   = p.hapticEnabled
    }
}

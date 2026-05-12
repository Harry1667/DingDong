import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var notifyThreshold: Int {
        didSet { PersistenceService.shared.notifyThreshold = notifyThreshold }
    }
    @Published var notifyMode: NotifyMode {
        didSet { PersistenceService.shared.notifyMode = notifyMode }
    }

    init() {
        let p = PersistenceService.shared
        notifyThreshold = p.notifyThreshold
        notifyMode = p.notifyMode
    }
}

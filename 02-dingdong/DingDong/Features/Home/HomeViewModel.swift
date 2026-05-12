import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var tasks: [TrackingTask] = []

    private var cancellables = Set<AnyCancellable>()

    init(trackingService: TrackingService) {
        trackingService.$tasks
            .receive(on: DispatchQueue.main)
            .assign(to: \.tasks, on: self)
            .store(in: &cancellables)
    }
}

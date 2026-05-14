import Foundation

@MainActor
final class FavoriteService: ObservableObject {
    static let shared = FavoriteService()
    private init() { favorites = PersistenceService.shared.favoriteDoctors }

    @Published private(set) var favorites: [FavoriteDoctor] = []

    func isFavorite(hospitalCode: String, doctorName: String, clinicRoom: String) -> Bool {
        favorites.contains {
            $0.hospitalCode == hospitalCode &&
            $0.doctorName   == doctorName   &&
            $0.clinicRoom   == clinicRoom
        }
    }

    func toggle(hospitalCode: String, hospitalName: String, department: String,
                doctorName: String, clinicRoom: String) {
        PersistenceService.shared.toggleFavorite(
            hospitalCode: hospitalCode, hospitalName: hospitalName,
            department: department, doctorName: doctorName, clinicRoom: clinicRoom
        )
        favorites = PersistenceService.shared.favoriteDoctors
    }

    func remove(_ fav: FavoriteDoctor) {
        PersistenceService.shared.removeFavorite(id: fav.id)
        favorites = PersistenceService.shared.favoriteDoctors
    }
}

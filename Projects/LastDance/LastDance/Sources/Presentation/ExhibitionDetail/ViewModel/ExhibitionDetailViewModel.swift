import SwiftUI
import SwiftData // Make sure SwiftData is imported for PersistentModel operations

@MainActor
final class ExhibitionDetailViewModel: ObservableObject {
    @Published var exhibition: Exhibition?
    @Published var artistNames: [String] = []
    @Published var showErrorAlert = false

    private let dataManager = SwiftDataManager.shared
    private let artistAPIService: ArtistAPIServiceProtocol // Added dependency

    private var currentArtistId: Int? // To store the ID of the current artist

    init(artistAPIService: ArtistAPIServiceProtocol = ArtistAPIService()) {
        self.artistAPIService = artistAPIService
    }

    /// 전시 정보 가져오기
    func fetchExhibition(by id: Int ) {
        // TODO: SwiftDataManager.fetchById 사용 시 predicate 오류 발생
        // 임시로 fetchAll 후 필터링 사용
        let allExhibitions = dataManager.fetchAll(Exhibition.self)
        exhibition = allExhibitions.first { $0.id == id }

        if exhibition != nil {
            fetchArtistNames()
            // Also fetch the current artist ID when the view model loads
            fetchCurrentArtistId()
        } else {
            showErrorAlert = true
        }
    }

    /// 전시 정보 존재 여부
    var hasExhibition: Bool {
        exhibition != nil
    }

    /// 작가 이름 가져오기
    private func fetchArtistNames() {
        guard let exhibition = exhibition else { return }

        let allArtists = dataManager.fetchAll(Artist.self)
        let artistIds = exhibition.artworks.compactMap { $0.artistId }
        artistNames = allArtists
            .filter { artistIds.contains($0.id) }
            .map { $0.name }
    }

    /// 현재 아티스트 ID 가져오기
    private func fetchCurrentArtistId() {
        guard let artistUUID = UserDefaults.standard.string(forKey: UserDefaultsKey.artistUUID.rawValue) else {
            Log.error("ExhibitionDetailViewModel: Artist UUID not found in UserDefaults.")
            return
        }

        artistAPIService.getArtistByUUID(artistUUID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let artistDto):
                self.currentArtistId = artistDto.id
                Log.debug("ExhibitionDetailViewModel: Current artist ID fetched: \(artistDto.id)")
            case .failure(let error):
                Log.error("ExhibitionDetailViewModel: Failed to fetch current artist by UUID: \(error.localizedDescription)")
            }
        }
    }

    /// 날짜 범위 포맷팅
    func formatDateRange(start: String, end: String) -> String {
        return Date.formatDateRange(start: start, end: end)
    }

    /// 전시를 \"나의 전시\"로 저장하고 아티스트와 연결
    func selectExhibitionAsUserExhibition() {
        guard let exhibition = exhibition else {
            Log.error("ExhibitionDetailViewModel: No exhibition to save.")
            return
        }
        guard let artistId = currentArtistId else {
            Log.error("ExhibitionDetailViewModel: Current artist ID is not available to link exhibition.")
            return
        }

        // 1. Set isUserSelected flag
        exhibition.isUserSelected = true

        // 2. Link exhibition to the current artist in SwiftData
        let allArtists = dataManager.fetchAll(Artist.self)
        if let currentArtist = allArtists.first(where: { $0.id == artistId }) {
            if !currentArtist.exhibitions.contains(exhibition.id) {
                currentArtist.exhibitions.append(exhibition.id)
                Log.debug("ExhibitionDetailViewModel: Added exhibition \(exhibition.id) to artist \(artistId)'s exhibitions.")
            }
        } else {
            Log.warning("ExhibitionDetailViewModel: Current artist (ID: \(artistId)) not found in SwiftData.")
        }

        // 3. Update artworks within this exhibition to be associated with the current artist
        for artwork in exhibition.artworks {
            if artwork.artistId != artistId { // Only update if different
                artwork.artistId = artistId
                Log.debug("ExhibitionDetailViewModel: Updated artwork \(artwork.id) artistId to \(artistId).")
            }
        }

        dataManager.saveContext()
        Log.debug("ExhibitionDetailViewModel: Exhibition '\(exhibition.title)' saved as user's exhibition and linked to artist \(artistId).")
    }
}
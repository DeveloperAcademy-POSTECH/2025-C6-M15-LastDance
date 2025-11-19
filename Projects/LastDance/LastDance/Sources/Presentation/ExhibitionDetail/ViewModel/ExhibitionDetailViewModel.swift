//
//  ExhibitionDetailViewModel.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftData
import SwiftUI

@MainActor
final class ExhibitionDetailViewModel: ObservableObject {
    @Published var exhibition: Exhibition?
    @Published var artistNames: [String] = []
    @Published var showErrorAlert = false

    private let dataManager = SwiftDataManager.shared
    private let artistAPIService: ArtistAPIServiceProtocol  // Added dependency
    private let visitHistoriesAPIService: VisitHistoriesAPIServiceProtocol
    private let exhibitionAPIService: ExhibitionAPIServiceProtocol

    private var currentArtistId: Int?  // To store the ID of the current artist

    init(
        artistAPIService: ArtistAPIServiceProtocol = ArtistAPIService(),
        visitHistoriesAPIService: VisitHistoriesAPIServiceProtocol = VisitHistoriesAPIService(),
        exhibitionAPIService: ExhibitionAPIServiceProtocol = ExhibitionAPIService()
    ) {
        self.artistAPIService = artistAPIService
        self.visitHistoriesAPIService = visitHistoriesAPIService
        self.exhibitionAPIService = exhibitionAPIService
    }

    /// 전시 정보 가져오기
    func fetchExhibition(by id: Int) {
        // API로 전시 상세 정보 가져오기 (artworks 포함)
        exhibitionAPIService.getDetailExhibition(exhibitionId: id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let exhibitionDto):
                Log.debug(
                    "fetchExhibition: API로 전시 상세 조회 성공 - id: \(id), title: \(exhibitionDto.title)")

                // 로컬 DB에서 가져오기 (API 호출 시 이미 저장됨)
                let allExhibitions = self.dataManager.fetchAll(Exhibition.self)
                self.exhibition = allExhibitions.first { $0.id == id }

                if let exhibition = self.exhibition {
                    Log.debug(
                        "fetchExhibition: Found exhibition with id \(id), artworks count: \(exhibition.artworks.count)"
                    )
                    self.fetchArtistNames()

                    // Also fetch the current artist ID when the view model loads
                    if let userTypeValue = UserDefaults.standard.string(
                        forKey: UserDefaultsKey.userType.key),
                        let userType = UserType(rawValue: userTypeValue),
                        userType == .artist
                    {
                        self.fetchCurrentArtistId()
                    }
                } else {
                    Log.debug("fetchExhibition: Exhibition not found in local DB after API call")
                    self.showErrorAlert = true
                }

            case .failure(let error):
                Log.error("fetchExhibition: API 호출 실패 - \(error)")
                // API 실패 시 로컬 DB에서 시도
                let allExhibitions = self.dataManager.fetchAll(Exhibition.self)
                self.exhibition = allExhibitions.first { $0.id == id }

                if let exhibition = self.exhibition {
                    Log.debug("fetchExhibition: Found exhibition in local DB (fallback)")
                    self.fetchArtistNames()
                } else {
                    self.showErrorAlert = true
                }
            }
        }
    }

    /// 전시 정보 존재 여부
    var hasExhibition: Bool {
        exhibition != nil
    }

    /// 작가 이름 가져오기
    private func fetchArtistNames() {
        guard let exhibition = exhibition else {
            Log.debug("fetchArtistNames: exhibition is nil")
            return
        }

        let allArtists = dataManager.fetchAll(Artist.self)
        let artistIds = exhibition.artworks.compactMap { $0.artistId }

        Log.debug("fetchArtistNames: exhibition.artworks count = \(exhibition.artworks.count)")
        Log.debug("fetchArtistNames: artistIds = \(artistIds)")
        Log.debug("fetchArtistNames: allArtists count = \(allArtists.count)")

        artistNames =
            allArtists
            .filter { artistIds.contains($0.id) }
            .map { $0.name }

        Log.debug("fetchArtistNames: artistNames = \(artistNames)")
    }

    /// 현재 아티스트 ID 가져오기
    private func fetchCurrentArtistId() {
        guard
            let artistUUID = UserDefaults.standard.string(
                forKey: UserDefaultsKey.artistUUID.rawValue)
        else {
            Log.error("Artist UUID not found in UserDefaults.")
            return
        }

        artistAPIService.getArtistByUUID(artistUUID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let artistDto):
                self.currentArtistId = artistDto.id
                Log.debug("Current artist ID fetched: \(artistDto.id)")
            case .failure(let error):
                Log.error("Failed to fetch current artist by UUID: \(error.localizedDescription)")
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
            Log.error("No exhibition to save.")
            return
        }

        exhibition.isUserSelected = true
        Log.debug(
            "ExhibitionDetailViewModel: Flag 'isUserSelected' set to true for exhibition '\(exhibition.title)'."
        )

        if let artistId = currentArtistId {
            Log.debug("Running artist-specific logic for selecting exhibition.")
            let allArtists = dataManager.fetchAll(Artist.self)
            if let currentArtist = allArtists.first(where: { $0.id == artistId }) {
                if !currentArtist.exhibitions.contains(exhibition.id) {
                    currentArtist.exhibitions.append(exhibition.id)
                    Log.debug(
                        "Added exhibition \(exhibition.id) to artist \(artistId)'s exhibitions.")
                }
            } else {
                Log.warning("Current artist (ID: \(artistId)) not found in SwiftData.")
            }

            for artwork in exhibition.artworks {
                if artwork.artistId != artistId {
                    artwork.artistId = artistId
                    Log.debug("Updated artwork \(artwork.id) artistId to \(artistId).")
                }
            }
        }

        Log.debug("ExhibitionDetailViewModel: Staged changes for exhibition '\(exhibition.title)'.")
    }

    /// 방문 기록 생성 API 함수
    func createVisitHistory(completion: @escaping (Bool) -> Void) {
        // UserDefaults에서 저장된 visitorUUID 가져오기
        guard
            let visitorUUID = UserDefaults.standard.string(
                forKey: UserDefaultsKey.visitorUUID.rawValue)
        else {
            Log.error("visitorUUID를 찾을 수 없습니다")
            completion(false)
            return
        }

        // SwiftData에서 UUID로 Visitor 조회
        let visitors = dataManager.fetchAll(Visitor.self)
        guard let visitor = visitors.first(where: { $0.uuid == visitorUUID }) else {
            Log.error("Visitor를 찾을 수 없습니다")
            completion(false)
            return
        }

        guard let exhibition = exhibition else {
            completion(false)
            return
        }

        let request = MakeVisitHistoriesRequestDto(
            visitor_id: visitor.id,
            exhibition_id: exhibition.id
        )

        visitHistoriesAPIService.makeVisitHistories(request: request) { result in
            switch result {
            case .success(let dto):
                Log.debug("방문 기록 생성 성공: visitId=\(dto.id)")
                UserDefaults.standard.set(dto.id, forKey: UserDefaultsKey.visitId.rawValue)
                completion(true)
            case .failure(let error):
                Log.error("방문 기록 생성 실패: \(error)")
                completion(false)
            }
        }
    }
}

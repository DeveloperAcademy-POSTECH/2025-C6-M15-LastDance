//
//  ExhibitionDetailViewModel.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

@MainActor
final class ExhibitionDetailViewModel: ObservableObject {
    @Published var exhibition: Exhibition?
    @Published var artistNames: [String] = []
    @Published var showErrorAlert = false

    private let dataManager = SwiftDataManager.shared

    /// 전시 정보 가져오기
    func fetchExhibition(by id: Int ) {
        // TODO: SwiftDataManager.fetchById 사용 시 predicate 오류 발생
        // 임시로 fetchAll 후 필터링 사용
        let allExhibitions = dataManager.fetchAll(Exhibition.self)
        exhibition = allExhibitions.first { $0.id == id }

        if exhibition != nil {
            fetchArtistNames()
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

    /// 날짜 범위 포맷팅
    func formatDateRange(start: String, end: String) -> String {
        return Date.formatDateRange(start: start, end: end)
    }
    /// 전시를 "나의 전시"로 저장
    func selectExhibitionAsUserExhibition() {
        guard let exhibition = exhibition else { return }
        
        exhibition.isUserSelected = true
        dataManager.saveContext()
        Log.debug("전시 '\(exhibition.title)'를 나의 전시로 저장했습니다.")
    }
}

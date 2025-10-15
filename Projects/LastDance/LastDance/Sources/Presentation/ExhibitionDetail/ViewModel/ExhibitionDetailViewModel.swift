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

    private let dataManager = SwiftDataManager.shared

    /// 전시 정보 가져오기
    func fetchExhibition(by id: String) {
        // TODO: SwiftDataManager.fetchById 사용 시 predicate 오류 발생
        // 임시로 fetchAll 후 필터링 사용
        let allExhibitions = dataManager.fetchAll(Exhibition.self)
        exhibition = allExhibitions.first { $0.id == id }

        if exhibition != nil {
            fetchArtistNames()
        }
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
    func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일(E)"
        formatter.locale = Locale(identifier: "ko_KR")

        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)

        return "\(startString)~ \(endString)"
    }
}

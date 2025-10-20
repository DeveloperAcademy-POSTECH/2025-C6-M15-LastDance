//
//  CompleteArticleListViewModel.swift
//  LastDance
//
//  Created by donghee, 신얀 on 10/16/25.
//

import SwiftUI

@MainActor
final class CompleteArticleListViewModel: ObservableObject {
    @Published var exhibition: Exhibition?
    @Published var artist: Artist?

    private let dataManager = SwiftDataManager.shared

    /// 전시 및 작가 정보 가져오기
    func fetchData(exhibitionId: Int, artistId: Int) {
        let allExhibitions = dataManager.fetchAll(Exhibition.self)
        let allArtists = dataManager.fetchAll(Artist.self)

        Log.debug("전체 전시 수: \(allExhibitions.count), 전체 작가 수: \(allArtists.count)")

        exhibition = allExhibitions.first { $0.id == exhibitionId }
        artist = allArtists.first { $0.id == artistId }

        Log.debug("로컬 DB 조회 - 전시: \(exhibition?.title ?? "없음"), 작가: \(artist?.name ?? "없음")")
    }
    
    /// 현재 화면에 표시된 "작가명/전시명"으로 전시 id 찾기
    func findExhibitionIdByCurrentFields() -> Int? {
        let allExhibitions = dataManager.fetchAll(Exhibition.self)
        let allArtists = dataManager.fetchAll(Artist.self)

        let artistName = (artist?.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let exhibitionTitle = (exhibition?.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !exhibitionTitle.isEmpty, !artistName.isEmpty else { return nil }

        // 전시명으로 찾기
        func norm(_ str: String) -> String { str.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        let titleKey = norm(exhibitionTitle)

        let candidates = allExhibitions.filter { norm($0.title) == titleKey }
        guard !candidates.isEmpty else { return nil }

        // 작가명으로 작가 찾고, 그 작가가 가진 exhibitions(id 리스트)와 교집합
        guard let theArtist = allArtists.first(where: { norm($0.name) == norm(artistName) }) else { return nil }
        let artistExhibitionIdSet = Set(theArtist.exhibitions)

        // candidates 중에서 artist.exhibitions에 포함된 id만 남김
        let narrowed = candidates.filter { artistExhibitionIdSet.contains($0.id) }

        // 최종 선택
        if let exact = narrowed.first {
            return exact.id
        } else {
            // 작가와의 매칭이 없으면 전시명만으로라도 1건 반환 (정책에 따라 nil 리턴해도 됨)
            return candidates.first?.id
        }
    }
}

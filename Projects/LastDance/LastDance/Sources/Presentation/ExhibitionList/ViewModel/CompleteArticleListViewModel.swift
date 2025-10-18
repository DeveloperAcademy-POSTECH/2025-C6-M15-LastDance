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
    func fetchData(exhibitionId: String, artistId: Int) {
        let allExhibitions = dataManager.fetchAll(Exhibition.self)
        let allArtists = dataManager.fetchAll(Artist.self)

        Log.debug("전체 전시 수: \(allExhibitions.count), 전체 작가 수: \(allArtists.count)")

        exhibition = allExhibitions.first { $0.id == exhibitionId }
        artist = allArtists.first { $0.id == artistId }

        Log.debug("로컬 DB 조회 - 전시: \(exhibition?.title ?? "없음"), 작가: \(artist?.name ?? "없음")")
    }
}

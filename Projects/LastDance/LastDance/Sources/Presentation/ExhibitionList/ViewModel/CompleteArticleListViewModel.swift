//
//  CompleteArticleListViewModel.swift
//  LastDance
//
//  Created by donghee on 10/16/25.
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

        exhibition = allExhibitions.first { $0.id == exhibitionId }
        artist = allArtists.first { $0.id == artistId }
    }
}

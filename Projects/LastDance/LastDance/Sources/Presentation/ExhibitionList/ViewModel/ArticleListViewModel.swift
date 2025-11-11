//
//  ArticleListViewModel.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftData
import SwiftUI

@MainActor
final class ArticleListViewModel: ObservableObject {
    @Published var artists: [Artist] = []
    @Published var filteredArtists: [Artist] = []
    @Published var searchText: String = "" {
        didSet {
            filterArtists()
        }
    }

    @Published var selectedArtistId: Int? = nil
    @Published var selectedArtistName: String = ""

    private let dataManager = SwiftDataManager.shared

    init() {
        fetchArtists()
    }

    /// 작가 목록 가져오기
    func fetchArtists() {
        artists = dataManager.fetchAll(Artist.self)
        filteredArtists = artists
        Log.debug("📊 Fetched \(artists.count) artists")
        for artist in artists {
            Log.debug("  - \(artist.name)")
        }
    }

    /// 작가 검색 필터링
    func filterArtists() {
        if searchText.isEmpty {
            filteredArtists = artists
        } else {
            filteredArtists = artists.filter { $0.name.contains(searchText) }
        }
    }

    /// 작가 선택 (이미 선택된 경우 선택 취소)
    func selectArtist(_ artist: Artist) {
        if selectedArtistId == artist.id {
            selectedArtistId = nil
            selectedArtistName = ""
        } else {
            selectedArtistId = artist.id
            selectedArtistName = artist.name
        }
    }

    /// 다음 버튼 탭
    func tapNextButton() -> Int? {
        guard let selectedId = selectedArtistId else {
            // TODO: 작가를 선택하지 않은 경우 예외 처리
            return nil
        }
        return selectedId
    }
}

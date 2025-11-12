//
//  ClipReactionInputViewModel.swift
//  LastDance
//
//  Created by 배현진 on 11/10/25.
//

import SwiftUI

@MainActor
final class ClipArtReactionViewModel: ObservableObject {
    @Published var artwork: Artwork?
    @Published var artist: Artist?
    @Published var message: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoaded: Bool = false
    @Published var isSending = false
    
    let limit = 500

    private let artworkId: Int
    private let exhibitionId: Int
    private let artworkService: ClipArtworkAPIServiceProtocol
    private let visitorService: ClipVisitorAPIServiceProtocol
    private let visitService: ClipVisitHistoriesAPIServiceProtocol
    private let reactionService: ClipReactionAPIServiceProtocol

    init(
        artworkId: Int,
        exhibitionId: Int,
        artworkService: ClipArtworkAPIServiceProtocol = ClipArtworkAPIService(),
        visitorService: ClipVisitorAPIServiceProtocol = ClipVisitorAPIService(),
        visitService: ClipVisitHistoriesAPIServiceProtocol = ClipVisitHistoriesAPIService(),
        reactionService: ClipReactionAPIServiceProtocol = ClipReactionAPIService()
    ) {
        self.artworkId = artworkId
        self.exhibitionId = exhibitionId
        self.artworkService = artworkService
        self.visitorService = visitorService
        self.visitService = visitService
        self.reactionService = reactionService
    }

    var artistName: String? {
        artist?.name
    }
    
    var hasText: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func loadArtwork() async {
        isLoading = true
        do {
            // 작품 상세 가져오기
            let fetchedArtwork = try await artworkService.loadArtworkDetail(id: artworkId)
            self.artwork = fetchedArtwork

            // 작가 정보도 있으면 가져오기
            if let artistId = fetchedArtwork.artistId {
                let fetchedArtist = try await artworkService.loadArtistDetail(id: artistId)
                self.artist = fetchedArtist
            }
            
            self.isLoaded = true
        } catch {
            Log.error("loadArtwork failed: \(error)")
            self.isLoaded = true
        }
        isLoading = false
    }

    func updateMessage(_ newValue: String) {
        if newValue.count > limit {
            message = String(newValue.prefix(limit))
        } else {
            message = newValue
        }
    }

    func isTabBarFixed(for scrollOffset: CGFloat) -> Bool {
        scrollOffset > 100
    }
    
    func sendReaction() async -> Bool {
        guard !isSending else { return false } // 중복 탭 방지
        isSending = true
        defer { isSending = false }
    
        do {
            // 기기 UUID 만들기 or 기존 거 꺼내기
            let uuid = UserDefaults.standard.string(
                forKey: UserDefaultsKey.visitorUUID.key
            ) ?? {
                let newUUID = UUID().uuidString
                UserDefaults.standard.set(newUUID, forKey: UserDefaultsKey.visitorUUID.key)
                return newUUID
            }()

            // 서버에서 이 uuid로 visitorId 확보
            let visitorId = try await visitorService.ensureVisitorId(for: uuid)
            
            // 서버에서 이 visitorId로 visitId 확보
            let visitId = try await visitService.ensureVisitId(
                visitorId: visitorId,
                exhibitionId: exhibitionId
            )

            // comment가 message고, imageUrl/tagIds는 없는 버전
            let dto = ReactionRequestDto(
                artworkId: artworkId,
                visitorId: visitorId,
                visitId: visitId,
                comment: message.isEmpty ? nil : message,
                imageUrl: nil,
                tagIds: nil
            )
            
            try await reactionService.createReaction(dto: dto)
            
            persistForMainApp(
                visitorUUID: uuid,
                visitorId: visitorId,
                visitId: visitId,
                exhibitionId: exhibitionId,
                artworkId: artworkId
            )
            
            Log.info("createReaction success")
            return true
        } catch {
            Log.error("createReaction error: \(error)")
            return false
        }
    }
    
    // MARK: - App과의 정보 공유를 위한 공유 공간 저장
    private func persistForMainApp(
        visitorUUID: String,
        visitorId: Int,
        visitId: Int,
        exhibitionId: Int,
        artworkId: Int?
    ) {
        guard let defaults = UserDefaults(suiteName: SharedKeys.suiteName) else { return }
        defaults.set(visitorUUID, forKey: SharedKeys.visitorUUID)
        defaults.set(visitorId, forKey: SharedKeys.visitorId)
        defaults.set(visitId, forKey: SharedKeys.visitId)
        defaults.set(exhibitionId, forKey: SharedKeys.exhibitionId)
        if let artworkId { defaults.set(artworkId, forKey: SharedKeys.lastArtworkId) }
        defaults.set(Date().timeIntervalSince1970, forKey: SharedKeys.savedAt)
    }
}

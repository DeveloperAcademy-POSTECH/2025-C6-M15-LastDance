//
//  ArtReactionViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/21/25.
//

import SwiftData
import SwiftUI

@MainActor
final class ArtReactionViewModel: ObservableObject {
    // MARK: - Properties

    @Published var reactions: [Reaction] = []
    @Published var isLoading = false

    private let artworkId: Int
    private let swiftDataManager = SwiftDataManager.shared
    private let reactionAPIService: ReactionAPIServiceProtocol
    private var refreshTimer: Timer?

    // MARK: - Initialization

    init(artworkId: Int, reactionAPIService: ReactionAPIServiceProtocol = ReactionAPIService()) {
        self.artworkId = artworkId
        self.reactionAPIService = reactionAPIService
    }

    // MARK: - Public Methods

    func loadReactions(showLoading: Bool = true) {
        if showLoading {
            isLoading = true
        }

        // 관람객 UUID로 visitorId 가져오기
        let visitorId = getVisitorId()

        reactionAPIService.getReactions(artworkId: artworkId, visitorId: visitorId, visitId: nil) {
            [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let getReactionDtos):
                let dispatchGroup = DispatchGroup()
                var fetchedReactions: [Reaction] = []
                let lock = NSLock()

                for getReactionDto in getReactionDtos {
                    dispatchGroup.enter()
                    self.reactionAPIService.getDetailReaction(reactionId: getReactionDto.id) {
                        detailResult in
                        defer { dispatchGroup.leave() }

                        switch detailResult {
                        case .success(let reactionResponseDto):
                            let reactionDetailDto = reactionResponseDto.data

                            // 작가 이모지 추출 (첫 번째 이모지만 사용)
                            let artistEmoji = reactionDetailDto.artist_emojis?.first?.emoji_type

                            // 작가 메시지 매핑
                            let artistMessages = reactionDetailDto.artist_messages?.map {
                                ArtistMessageInfo(
                                    id: $0.id,
                                    artistName: $0.artist_name,
                                    message: $0.message,
                                    createdAt: $0.created_at
                                )
                            }

                            let reaction = Reaction(
                                id: String(reactionDetailDto.id),
                                artworkId: reactionDetailDto.artwork_id,
                                visitorId: reactionDetailDto.visitor_id,
                                tags: [],
                                comment: reactionDetailDto.comment,
                                artistEmoji: artistEmoji,
                                artistMessages: artistMessages,
                                createdAt: reactionDetailDto.created_at
                            )

                            lock.lock()
                            fetchedReactions.append(reaction)
                            lock.unlock()

                        case .failure(let error):
                            Log.error("반응 ID \(getReactionDto.id) 상세 정보 조회 실패: \(error.localizedDescription)")
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    self.reactions = fetchedReactions.sorted { $0.id < $1.id }
                    if showLoading {
                        self.isLoading = false
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    if showLoading {
                        self.isLoading = false
                    }
                    Log.error("작품 \(self.artworkId)에 대한 반응 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 10초마다 자동 새로고침 시작
    func startAutoRefresh() {
        stopAutoRefresh()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            // 백그라운드 새로고침은 로딩 인디케이터 없이 조용히 진행
            self?.loadReactions(showLoading: false)
        }
    }

    /// 자동 새로고침 중지
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    // MARK: - Private Methods

    /// UserDefaults에서 visitorUUID를 가져와 SwiftData에서 visitorId 조회
    private func getVisitorId() -> Int? {
        guard let visitorUUID = UserDefaults.standard.string(
            forKey: UserDefaultsKey.visitorUUID.rawValue)
        else {
            return nil
        }

        let visitors = swiftDataManager.fetchAll(Visitor.self)
        guard let visitor = visitors.first(where: { $0.uuid == visitorUUID }) else {
            return nil
        }

        return visitor.id
    }
}

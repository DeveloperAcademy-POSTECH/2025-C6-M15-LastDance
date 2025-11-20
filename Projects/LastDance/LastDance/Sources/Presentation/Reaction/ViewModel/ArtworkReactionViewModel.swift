//
//  ArtworkReactionViewModel.swift
//  LastDance
//
//  Created by donghee on 10/20/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - ResponseViewModel

@MainActor
final class ArtworkReactionViewModel: ObservableObject {
    @Published var expandedReactions: Set<String> = []
    @Published var showAllReactions: [String: Bool] = [:]
    @Published var reactions: [ReactionData] = []
    @Published var isLoading = false
    @Published var selectedReactionId: String?  // 이모지 팝업 중 클릭한 반응의 ID 임시 저장
    @Published var selectedEmojis: [String: String] = [:]  // 실제 선택된 이모지 저장
    @Published var message: String = ""

    private let artworkId: Int
    private let reactionAPIService: ReactionAPIServiceProtocol
    private let swiftDataManager = SwiftDataManager.shared
    init(artworkId: Int, reactionAPIService: ReactionAPIServiceProtocol = ReactionAPIService()) {
        self.artworkId = artworkId
        self.reactionAPIService = reactionAPIService
        fetchReactions()
    }

    /// API를 통해 실제 반응 데이터를 불러오는 로직 구현
    func fetchReactions() {
        isLoading = true
        reactions = []

        reactionAPIService.getReactions(artworkId: artworkId, visitorId: nil, visitId: nil) {
            [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let getReactionDtos):
                Log.debug(
                    "Fetched \(getReactionDtos.count) GetReactionResponseDtos for artwork \(self.artworkId)."
                )

                let dispatchGroup = DispatchGroup()
                var fetchedReactionData: [ReactionData] = []
                let lock = NSLock()

                for getReactionDto in getReactionDtos {
                    dispatchGroup.enter()
                    self.reactionAPIService.getDetailReaction(reactionId: getReactionDto.id) {
                        detailResult in
                        defer { dispatchGroup.leave() }

                        switch detailResult {
                        case .success(let reactionResponseDto):
                            let reactionDetailDto = reactionResponseDto.data

                            // 현재 로그인한 작가의 이모지 찾기
                            let artistEmoji = reactionDetailDto.artist_emojis?.first?.emoji_type

                            // 작가 메시지 매핑
                            let artistMessages =
                                reactionDetailDto.artist_messages?.map {
                                    ReactionData.ArtistMessage(
                                        id: $0.id,
                                        artistName: $0.artist_name,
                                        message: $0.message,
                                        createdAt: $0.created_at
                                    )
                                } ?? []

                            Log.debug(
                                "Reaction ID \(reactionDetailDto.id): artist_messages count = \(artistMessages.count)"
                            )
                            if !artistMessages.isEmpty {
                                Log.debug("Artist messages: \(artistMessages.map { $0.message })")
                            }

                            let reactionData = ReactionData(
                                id: String(reactionDetailDto.id),
                                comment: reactionDetailDto.comment ?? "",
                                categories: reactionDetailDto.tags?.map { $0.name } ?? [],
                                artistEmoji: artistEmoji,
                                artistMessages: artistMessages,
                                createdAt: reactionDetailDto.created_at
                            )
                            lock.lock()
                            fetchedReactionData.append(reactionData)
                            lock.unlock()
                        case .failure(let error):
                            Log.error(
                                "Failed to fetch detail for reaction ID \(getReactionDto.id): \(error.localizedDescription)"
                            )
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    self.reactions = fetchedReactionData.sorted { $0.id < $1.id }

                    // API 응답으로부터 selectedEmojis 초기화
                    var emojis: [String: String] = [:]
                    for reaction in self.reactions {
                        if let emoji = reaction.artistEmoji {
                            emojis[reaction.id] = emoji
                        }
                    }
                    self.selectedEmojis = emojis

                    self.isLoading = false
                    Log.debug(
                        "All reaction details fetched and mapped for artwork \(self.artworkId). Total: \(self.reactions.count)"
                    )
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    Log.error(
                        "Failed to fetch reactions for artwork \(self.artworkId): \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    /// - Parameter id: 반응 ID
    func toggleExpandReaction(id: String) {
        if expandedReactions.contains(id) {
            expandedReactions.remove(id)
        } else {
            expandedReactions.insert(id)
        }
    }

    /// 특정 반응의 카테고리 전체 보기 상태를 토글합니다
    /// - Parameter id: 반응 ID
    func toggleShowAllReactions(id: String) {
        showAllReactions[id] = !(showAllReactions[id] ?? false)
    }

    /// 반응 카드의 확장 버튼 클릭 시 코멘트 확장과 카테고리 표시 상태를 함께 처리합니다
    /// - Parameter reaction: 토글할 반응 데이터
    func handleExpandToggle(for reaction: ReactionData) {
        let willExpand = !expandedReactions.contains(reaction.id)
        toggleExpandReaction(id: reaction.id)

        if willExpand {
            if !(showAllReactions[reaction.id] ?? false), reaction.categories.count > 1 {
                toggleShowAllReactions(id: reaction.id)
            }
        } else {
            if showAllReactions[reaction.id] ?? false {
                toggleShowAllReactions(id: reaction.id)
            }
        }
    }

    /// 반응의 코멘트를 확장 상태에 따라 전체 또는 축약하여 반환합니다
    /// - Parameter reaction: 표시할 반응 데이터
    /// - Returns: 확장 시 전체 코멘트, 축소 시 100자까지 축약된 코멘트
    func displayText(for reaction: ReactionData) -> String {
        if expandedReactions.contains(reaction.id) {
            return reaction.comment
        } else {
            return String(reaction.comment.prefix(100))
                + (reaction.comment.count > 100 ? "..." : "")
        }
    }

    /// 숨겨진 카테고리의 개수를 계산합니다
    /// - Parameter reaction: 반응 데이터
    /// - Returns: 첫 번째 카테고리를 제외한 나머지 카테고리 개수
    func hiddenCount(for reaction: ReactionData) -> Int {
        reaction.categories.count > 1 ? reaction.categories.count - 1 : 0
    }

    /// 작품 목록에서 특정 ID의 작품을 찾아 반환합니다
    /// - Parameters:
    ///   - artworks: 전체 작품 목록
    ///   - artworkId: 찾으려는 작품 ID
    /// - Returns: 해당 ID의 작품, 없으면 nil
    func getArtwork(from _: [Artwork], id artworkId: Int) -> Artwork? {
        return swiftDataManager.fetchAll(Artwork.self).first { $0.id == artworkId }
    }

    /// 첫 줄에 표시할 카테고리 목록을 반환합니다
    /// - Parameters:
    ///   - categories: 전체 카테고리 목록
    ///   - reactionId: 반응 ID
    /// - Returns: 전체 보기 시 2개, 축소 시 1개의 카테고리
    func firstLineCategories(for categories: [String], reactionId: String) -> [String] {
        let showAll = showAllReactions[reactionId] ?? false
        return Array(categories.prefix(showAll ? 2 : 1))
    }

    /// 숨겨진 카테고리 목록을 반환합니다
    /// - Parameters:
    ///   - categories: 전체 카테고리 목록
    ///   - reactionId: 반응 ID
    /// - Returns: 전체 보기 시 3번째 이후 카테고리, 그렇지 않으면 빈 배열
    func hiddenCategories(for categories: [String], reactionId: String) -> [String] {
        let showAll = showAllReactions[reactionId] ?? false
        if showAll, categories.count > 2 {
            return Array(categories.dropFirst(2))
        }
        return []
    }

    /// 선택된 이모지를 서버로 전송하는 함수
    /// - Parameter emoji: 선택된 이모지 asset 이름
    func sendEmoji(_ emoji: String) {
        guard let reactionIdString = selectedReactionId,
            let reactionId = Int(reactionIdString)
        else {
            Log.error("이모지를 보낼 수 없음")
            return
        }

        // artistUUID 가져오기
        guard
            let artistUUID = UserDefaults.standard.string(
                forKey: UserDefaultsKey.artistUUID.rawValue),
            !artistUUID.isEmpty
        else {
            Log.error("Artist UUID 를 찾지 못함")
            selectedReactionId = nil
            return
        }

        let dto = EmojiReactionRequestDto(emoji_type: emoji)

        reactionAPIService.createEmojiReaction(
            reactionId: reactionId,
            artistUUID: artistUUID,
            dto: dto
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                Log.debug("이모지 반응 전송 성공 - ID: \(response.id)")
                DispatchQueue.main.async {
                    self.selectedEmojis[reactionIdString] = emoji
                    self.selectedReactionId = nil
                }
            case .failure(let error):
                Log.error("이모지 반응 전송 실패: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.selectedReactionId = nil
                }
            }
        }
    }

    /// 특정 반응에 선택된 이모지를 반환
    /// - Parameter reactionId: 반응 ID
    /// - Returns: 선택된 이모지 asset 이름, 없으면 nil
    func getSelectedEmoji(for reactionId: String) -> String? {
        return selectedEmojis[reactionId]
    }

    /// 작가 메세지를 관람객에게 전달하는 함수
    /// - Parameters:
    ///   - reactionIdString: 반응 ID (String)
    ///   - message: 전송할 메시지 (10자 이내)
    ///   - completion: 전송 완료 후 실행될 클로저
    func sendMessage(
        _ reactionIdString: String, _ message: String, completion: @escaping (Bool) -> Void
    ) {
        guard let reactionId = Int(reactionIdString) else {
            Log.error("반응 ID 변환 실패")
            completion(false)
            return
        }

        guard
            let artistUUID = UserDefaults.standard.string(
                forKey: UserDefaultsKey.artistUUID.rawValue),
            !artistUUID.isEmpty
        else {
            Log.error("Artist UUID 를 찾지 못함")
            completion(false)
            return
        }

        let dto = MessageReactionRequestDto(message: message)

        reactionAPIService.createMessageReaction(
            reactionId: reactionId,
            artistUUID: artistUUID,
            dto: dto
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                Log.debug("메시지 반응 전송 성공 - ID: \(response.id)")
                self.handleMessageCreated(reactionIdString: reactionIdString, response: response)
                DispatchQueue.main.async {
                    self.message = ""
                    completion(true)
                }
            case .failure(let error):
                Log.error("메시지 반응 전송 실패: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    /// 메시지 생성 후 반응 데이터 업데이트
    private func handleMessageCreated(
        reactionIdString: String, response: MessageReactionResponseDto
    ) {
        guard let reactionIndex = reactions.firstIndex(where: { $0.id == reactionIdString }) else {
            Log.warning("반응 ID \(reactionIdString)를 찾을 수 없음")
            return
        }

        let newMessage = mapToArtistMessage(from: response)
        let updatedReaction = reactions[reactionIndex].addingMessage(newMessage)

        DispatchQueue.main.async { [weak self] in
            self?.reactions[reactionIndex] = updatedReaction
        }
    }

    /// MessageReactionResponseDto를 ArtistMessage로 변환
    private func mapToArtistMessage(from dto: MessageReactionResponseDto)
        -> ReactionData.ArtistMessage
    {
        return ReactionData.ArtistMessage(
            id: dto.id,
            artistName: dto.artist.name,
            message: dto.message,
            createdAt: dto.created_at
        )
    }
}

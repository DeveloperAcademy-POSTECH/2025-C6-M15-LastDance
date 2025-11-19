//
//  ResponseViewModel.swift
//  LastDance
//
//  Created by donghee on 10/20/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - ResponseViewModel

@MainActor
final class ResponseViewModel: ObservableObject {
    @Published var expandedReactions: Set<String> = []
    @Published var showAllReactions: [String: Bool] = [:]
    @Published var reactions: [ReactionData] = []
    @Published var isLoading = false  // Added isLoading property

    private let artworkId: Int  // Added artworkId property
    private let reactionAPIService: ReactionAPIServiceProtocol  // Added dependency
    private let swiftDataManager = SwiftDataManager.shared  // To fetch Artwork for display

    init(artworkId: Int, reactionAPIService: ReactionAPIServiceProtocol = ReactionAPIService()) {
        self.artworkId = artworkId
        self.reactionAPIService = reactionAPIService
        fetchReactions()  // Automatically fetch reactions on init
    }

    /// API를 통해 실제 반응 데이터를 불러오는 로직 구현
    func fetchReactions() {
        isLoading = true
        reactions = []  // Clear previous data

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
                let lock = NSLock()  // To protect fetchedReactionData during concurrent access

                for getReactionDto in getReactionDtos {
                    dispatchGroup.enter()
                    self.reactionAPIService.getDetailReaction(reactionId: getReactionDto.id) {
                        detailResult in
                        defer { dispatchGroup.leave() }

                        switch detailResult {
                        case .success(let reactionResponseDto):
                            let reactionDetailDto = reactionResponseDto.data  // This is ReactionDetailResponseDto
                            let reactionData = ReactionData(
                                id: String(reactionDetailDto.id),
                                comment: reactionDetailDto.comment ?? "",
                                categories: reactionDetailDto.tags.map { $0.name }
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
                    self.reactions = fetchedReactionData.sorted { $0.id < $1.id }  // Sort to maintain order
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
}

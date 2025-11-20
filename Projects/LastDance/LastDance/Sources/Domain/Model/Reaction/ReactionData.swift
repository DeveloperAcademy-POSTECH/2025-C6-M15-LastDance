//
//  ReactionData.swift
//  LastDance
//
//  Created by donghee on 10/20/25.
//

import Foundation

struct ReactionData: Identifiable {
    let id: String
    let comment: String
    let categories: [String]
    let artistEmoji: String?  // 작가가 선택한 이모지 (emoji_type)
    let artistMessages: [ArtistMessage]  // 작가가 남긴 메시지들
    let createdAt: String

    struct ArtistMessage: Identifiable {
        let id: Int
        let artistName: String
        let message: String
        let createdAt: String
    }

    /// 새로운 작가 메시지를 추가한 ReactionData 복사본 반환
    func addingMessage(_ message: ArtistMessage) -> ReactionData {
        var updatedMessages = artistMessages
        updatedMessages.append(message)
        return ReactionData(
            id: id,
            comment: comment,
            categories: categories,
            artistEmoji: artistEmoji,
            artistMessages: updatedMessages,
            createdAt: createdAt
        )
    }
}

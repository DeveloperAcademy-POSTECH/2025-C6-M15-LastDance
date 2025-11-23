//
//  ReactionMapper.swift
//  LastDance
//
//  Created by 배현진 on 10/20/25.
//

enum ReactionMapper {
    /// ReactionDetail DTO를 Reaction Model로 변환
    static func mapDtoToModel(_ dto: ReactionDetailResponseDto) -> Reaction {
        //        let tags = dto.tags.map {
        //            ReactionTagInfo(name: $0.name, colorHex: $0.color_hex ?? "#8F8F8F")
        //        }  // Fallback to gray

        // 작가 이모지 추출 (첫 번째 이모지만 사용)
        let artistEmoji = dto.artist_emojis?.first?.emoji_type

        // 작가 메시지 매핑
        let artistMessages = dto.artist_messages?.map {
            ArtistMessageInfo(
                id: $0.id,
                artistName: $0.artist_name,
                message: $0.message,
                createdAt: $0.created_at
            )
        }

        return Reaction(
            id: String(dto.id),
            artworkId: dto.artwork_id,
            visitorId: dto.visitor_id,
            //            tags: tags,
            comment: dto.comment,
            artistEmoji: artistEmoji,
            artistMessages: artistMessages,
            createdAt: dto.created_at
        )
    }

    /// Reaction DTO를 Reaction Model로 변환
    static func mapDtoToModel(_ dto: GetReactionResponseDto) -> Reaction {
        return Reaction(
            id: String(dto.id),
            artworkId: dto.artwork_id,
            visitorId: dto.visitor_id,
            tags: [],  // This DTO has no tag details
            comment: dto.comment,
            createdAt: dto.created_at
        )
    }
}

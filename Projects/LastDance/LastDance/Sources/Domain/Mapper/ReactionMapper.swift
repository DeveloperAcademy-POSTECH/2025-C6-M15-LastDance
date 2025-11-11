//
//  ReactionMapper.swift
//  LastDance
//
//  Created by 배현진 on 10/20/25.
//

enum ReactionMapper {
    /// ReactionDetail DTO를 Reaction Model로 변환
    static func mapDtoToModel(_ dto: ReactionDetailResponseDto) -> Reaction {
        let tags = dto.tags.map {
            ReactionTagInfo(name: $0.name, colorHex: $0.color_hex ?? "#8F8F8F")
        }  // Fallback to gray

        return Reaction(
            id: String(dto.id),
            artworkId: dto.artwork_id,
            visitorId: dto.visitor_id,
            tags: tags,
            comment: dto.comment,
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

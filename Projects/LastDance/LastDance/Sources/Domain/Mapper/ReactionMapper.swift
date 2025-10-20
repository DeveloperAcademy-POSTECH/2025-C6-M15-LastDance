//
//  ReactionMapper.swift
//  LastDance
//
//  Created by 배현진 on 10/20/25.
//

enum ReactionMapper {
    /// ReactionDetail DTO를 Reaction Model로 변환
    static func mapDtoToModel(_ dto: ReactionDetailResponseDto) -> Reaction {
        // tags를 category 문자열 배열로 변환
        let categories = dto.tags.map { $0.name }
        
        return Reaction(
            id: String(dto.id),
            artworkId: dto.artwork_id,
            visitorId: dto.visitor_id,
            category: categories,
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
            category: [],
            comment: dto.comment,
            createdAt: dto.created_at
        )
    }
}

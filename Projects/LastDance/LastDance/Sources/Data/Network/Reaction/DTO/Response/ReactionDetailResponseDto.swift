//
//  ReactionDetailResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 10/16/25.
//

// MARK: ReactionDetailResponseDto

struct ReactionDetailResponseDto: Codable {
    let id: Int
    let artwork_id: Int
    let visitor_id: Int
    let visit_id: Int?
    let comment: String?
    let image_url: String?
    let created_at: String
    let updated_at: String?
    let artwork: ArtworkDetailResponseDto
    let visitor: VisitorResponseDto
    let tags: [TagDetailResponseDto]
}

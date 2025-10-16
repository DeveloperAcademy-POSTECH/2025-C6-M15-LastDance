//
//  GetReactionResponseDto.swift
//  LastDance
//
//  Created by 신얀 on 10/16/25.
//
import Foundation

struct GetReactionResponseDto: Codable {
    let id: Int
    let artwork_id: Int
    let visitor_id: Int
    let visit_id: Int?
    let comment: String?
    let image_url: String?
    let created_at: String
    let updated_at: String?
}

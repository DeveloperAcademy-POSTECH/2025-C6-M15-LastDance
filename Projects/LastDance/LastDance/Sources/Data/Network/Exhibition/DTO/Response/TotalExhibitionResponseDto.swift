//
//  TotalExhibitionResponseDto.swift
//  LastDance
//
//  Created by D��� on 10/16/25.
//

import Foundation

// MARK: TotalExhibitionResponseDto
struct TotalExhibitionResponseDto: Codable, ExhibitionDtoMappableProtocol {
    let id: Int
    let title: String
    let description_text: String?
    let start_date: String
    let end_date: String
    let venue_id: Int
    let cover_image_url: String?
    let created_at: String
    let updated_at: String?
}

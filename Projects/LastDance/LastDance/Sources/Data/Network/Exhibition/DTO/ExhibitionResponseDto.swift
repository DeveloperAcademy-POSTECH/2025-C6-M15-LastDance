//
//  ExhibitionResponseDto.swift
//  LastDance
//
//  Created by D��� on 10/16/25.
//

import Foundation

// MARK: ExhibitionResponseDto
struct ExhibitionResponseDto: Codable {
    let id: Int
    let title: String
    let description_text: String?
    let start_date: String
    let end_date: String
    let venue_id: Int
    let cover_image_url: String?
    let created_at: String
    let updated_at: String
}

// MARK: ExhibitionResponseDto
/// 해당 파일에서만 사용되는 extension 입니다.
extension ExhibitionResponseDto {
    func toEntity() -> Exhibition {
        let dateFormatter = ISO8601DateFormatter()
        let start = dateFormatter.date(from: start_date) ?? Date()
        let end = dateFormatter.date(from: end_date) ?? Date()

        return Exhibition(
            id: String(id),
            title: title,
            descriptionText: description_text,
            startDate: start,
            endDate: end,
            venueId: String(venue_id),
            coverImageName: cover_image_url
        )
    }
}

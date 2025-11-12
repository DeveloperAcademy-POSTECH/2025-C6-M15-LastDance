//
//  ExhibitionDtoMapper.swift
//  LastDance
//
//  Created by 아우신얀 on 10/17/25.
//

import Foundation

// MARK: ExhibitionDtoMappableProtocol

/// Exhibition DTO를 Entity로 변환하기 위한 공통 프로토콜
protocol ExhibitionDtoMappableProtocol {
    var id: Int { get }
    var title: String { get }
    var description_text: String? { get }
    var start_date: String { get }
    var end_date: String { get }
    var venue_id: Int { get }
    var cover_image_url: String? { get }
    var created_at: String { get }
    var updated_at: String? { get }
}

// MARK: ExhibitionDtoMappable

extension ExhibitionDtoMappableProtocol {
    func toEntity() -> Exhibition {
        return Exhibition(
            id: id,
            title: title,
            descriptionText: description_text,
            startDate: Date.formatAPIDate(from: start_date),
            endDate: Date.formatAPIDate(from: end_date),
            venueId: venue_id,
            coverImageName: cover_image_url,
            createdAt: Date.formatAPIDate(from: created_at),
            updatedAt: updated_at.flatMap { Date.formatAPIDate(from: $0) }
        )
    }
}

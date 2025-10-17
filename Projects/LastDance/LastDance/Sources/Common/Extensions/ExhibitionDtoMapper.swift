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
}

// MARK: ExhibitionDtoMappable
extension ExhibitionDtoMappableProtocol {
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

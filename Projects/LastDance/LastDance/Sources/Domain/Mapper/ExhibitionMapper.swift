//
//  ExhibitionMapper.swift
//  LastDance
//
//  Created by 배현진 on 11/12/25.
//

enum ExhibitionMapper {
    static func toModel(from dto: ExhibitionResponseDto) -> Exhibition {
        Exhibition(
            id: dto.id,
            title: dto.title,
            descriptionText: dto.description_text,
            startDate: dto.start_date,
            endDate: dto.end_date,
            venueId: dto.venue_id,
            coverImageName: dto.cover_image_url,
            createdAt: dto.created_at,
            updatedAt: dto.updated_at
        )
    }
}

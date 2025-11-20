//
//  InvitationMapper.swift
//  LastDance
//
//  Created by donghee on 11/20/25.
//

enum InvitationMapper {
    static func toModel(from dto: InvitationResponseDto) -> Invitation {
        Invitation(
            id: dto.id,
            exhibitionId: dto.exhibition.id,
            exhibitionTitle: dto.exhibition.title,
            artistName: dto.artist.name,
            venueName: dto.exhibition.venue.name,
            venueAddress: dto.exhibition.venue.address,
            startDate: dto.exhibition.start_date,
            endDate: dto.exhibition.end_date,
            coverImageName: dto.exhibition.cover_image_url,
            invitationMessage: dto.message ?? "",
            visitorCount: dto.view_count ?? 0,
            createdAt: dto.created_at,
            deepLink: dto.deep_link,
            appStoreLink: dto.app_store_link
        )
    }
}

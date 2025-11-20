//
//  InvitationResponseDto.swift
//  LastDance
//
//  Created by donghee on 11/17/25.
//

import Foundation

// MARK: - InvitationResponseDto

struct InvitationResponseDto: Codable {
    let id: Int
    let code: String
    let artist: ArtistInInvitation
    let exhibition: ExhibitionInInvitation
    let message: String?
    let view_count: Int?
    let created_at: String
    let updated_at: String?
    let deep_link: String?
    let app_store_link: String?
}

// MARK: - ArtistInInvitation

struct ArtistInInvitation: Codable {
    let id: Int
    let name: String
    let bio: String?
}

// MARK: - ExhibitionInInvitation

struct ExhibitionInInvitation: Codable {
    let id: Int
    let title: String
    let description_text: String?
    let start_date: String
    let end_date: String
    let cover_image_url: String?
    let venue: VenueInInvitation
}

// MARK: - VenueInInvitation

struct VenueInInvitation: Codable {
    let name: String
    let address: String
    let geo_lat: Double?
    let geo_lon: Double?
}

//
//  ExhibitionResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 10/16/25.
//

import Foundation

struct ExhibitionResponseDto: Codable, ExhibitionDtoMappableProtocol {
    let id: Int
    let title: String
    let description_text: String?
    let start_date: String
    let end_date: String
    let venue_id: Int
    let cover_image_url: String?
    let created_at: String
    let updated_at: String?
    let venue: VenueInfo
    let artworks: [ArtworkInfo]?

    struct VenueInfo: Codable {
        let id: Int
        let name: String
        let address: String?
        let geo_lat: Double?
        let geo_lon: Double?
        let created_at: String
        let updated_at: String?
    }

    struct ArtworkInfo: Codable {
        let id: Int
        let title: String
        let artist_id: Int
        let description: String?
        let year: Int?
        let thumbnail_url: String?
        let created_at: String
        let updated_at: String?
    }
}

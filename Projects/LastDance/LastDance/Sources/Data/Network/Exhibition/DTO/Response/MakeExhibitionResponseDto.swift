//
//  MakeExhibitionResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 10/16/25.
//

import Foundation


struct MakeExhibitionResponseDto: Codable {
    let id: Int
    let title: String
    let artist_id: Int
    let description: String?
    let year: Int?
    let thumbnail_url: String?
    let created_at: String
    let updated_at: String?
    let artist: ArtistInfo
    let exhibitions: [ExhibitionDetail]
    
    struct ArtistInfo: Codable {
        let id: Int
        let uuid: String
        let name: String
        let bio: String?
        let email: String?
        let created_at: String
        let updated_at: String?
    }

    struct ExhibitionDetail: Codable {
        let id: Int
        let title: String
        let description_text: String?
        let start_date: String
        let end_date: String
        let venue_id: String
        let cover_image_url: String?
        let created_at: String
        let updated_at: String?
    }
}

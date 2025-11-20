//
//  ArtistCodeResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 11/17/25.
//

struct ArtistCodeResponseDto: Codable {
    let id: Int
    let uuid: String
    let name: String
    let bio: String?
    let email: String?
}

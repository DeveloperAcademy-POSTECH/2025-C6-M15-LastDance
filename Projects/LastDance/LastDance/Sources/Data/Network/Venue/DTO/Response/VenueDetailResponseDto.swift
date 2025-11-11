//
//  VenueDetailResponseDto.swift
//  LastDance
//
//  Created by 배현진 on 10/18/25.
//

struct VenueDetailResponseDto: Codable {
    let id: Int
    let name: String
    let address: String
    let geo_lat: Double?
    let geo_lon: Double?
    let created_at: String
    let updated_at: String?
}

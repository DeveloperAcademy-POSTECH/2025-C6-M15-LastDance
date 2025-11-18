//
//  ArtworkMatchResponseDto.swift
//  LastDance
//
//  Created by 배현진 on 11/17/25.
//

struct ArtworkMatchResponseDto: Codable {
    let matched: Bool
    let total_matches: Int
    let threshold: Double
    let results: [ArtworkMatchResultDto]
}

// 응답 결과 한 개
struct ArtworkMatchResultDto: Codable {
    let artwork_id: Int
    let title: String
    let artist_id: Int
    let artist_name: String
    let thumbnail_url: String?
    let similarity: Double
    let exhibitions: [ArtworkMatchExhibitionDto]
}

// 응답 내부 Exhibition 정보
struct ArtworkMatchExhibitionDto: Codable {
    let id: Int
    let title: String
    let venue_name: String
}

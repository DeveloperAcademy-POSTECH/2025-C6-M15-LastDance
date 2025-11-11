//
//  VisitorHistoriesResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 10/20/25.
//

struct VisitorHistoriesResponseDto: Codable {
    let id: Int
    let visitor_id: Int
    let exhibition_id: Int
    let visited_at: String
}

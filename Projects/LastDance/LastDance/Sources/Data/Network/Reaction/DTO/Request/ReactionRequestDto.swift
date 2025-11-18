//
//  ReactionRequestDto.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation

struct ReactionRequestDto {
    let artworkId: Int
    let visitorId: Int
    let visitId: Int
    let comment: String?
    let imageData: Data?
    let tagIds: [Int]?
}

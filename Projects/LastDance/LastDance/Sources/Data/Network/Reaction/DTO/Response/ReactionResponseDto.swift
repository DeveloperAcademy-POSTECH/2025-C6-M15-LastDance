//
//  ReactionResponseDto.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation

// MARK: ReactionResponseDto

struct ReactionResponseDto: Codable {
    let code: Int
    let data: ReactionDetailResponseDto
}

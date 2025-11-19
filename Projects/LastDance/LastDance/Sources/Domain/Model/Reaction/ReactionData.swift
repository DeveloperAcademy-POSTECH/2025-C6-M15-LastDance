//
//  ReactionData.swift
//  LastDance
//
//  Created by donghee on 10/20/25.
//

import Foundation

struct ReactionData: Identifiable {
    let id: String
    let comment: String
    let categories: [String]
    let artistEmoji: String?  // 작가가 선택한 이모지 (emoji_type)
}

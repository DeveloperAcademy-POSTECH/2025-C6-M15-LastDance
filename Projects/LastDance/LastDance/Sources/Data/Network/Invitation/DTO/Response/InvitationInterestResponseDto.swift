//
//  InvitationInterestResponseDto.swift
//  LastDance
//
//  Created by donghee on 11/19/25.
//

import Foundation

/// 초대장 관심 표현 (갈게요) Response DTO
struct InvitationInterestResponseDto: Codable {
    let id: Int
    let invitation_id: Int
    let visitor_id: Int
    let created_at: String
}

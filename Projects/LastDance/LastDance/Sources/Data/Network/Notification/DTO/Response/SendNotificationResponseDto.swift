//
//  SendNotificationResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 11/18/25.
//

struct SendNotificationResponseDto: Codable {
    let message: String
    let environment: String
    let success_count: Int
    let failed_count: Int
}

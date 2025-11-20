//
//  SendNotificationRequestDto.swift
//  LastDance
//
//  Created by 아우신얀 on 11/18/25.
//

import Foundation

struct SendNotificationRequestDto: Codable {
    let visitor_id: Int?
    let artist_id: Int?
    let device_token: String?
    let title: String
    let body: String
    let data: [String: String]?
    let badge: Int?
    let use_sandbox: Bool?
}

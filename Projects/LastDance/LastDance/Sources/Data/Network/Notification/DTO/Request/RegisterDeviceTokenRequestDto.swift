//
//  RegisterDeviceTokenRequestDto.swift
//  LastDance
//
//  Created by 아우신얀 on 11/16/25.
//

import Foundation

struct RegisterDeviceTokenRequestDto: Codable {
    let visitorId: Int?
    let artistId: Int?
    let deviceToken: String

    enum CodingKeys: String, CodingKey {
        case visitorId = "visitor_id"
        case artistId = "artist_id"
        case deviceToken = "device_token"
    }
}

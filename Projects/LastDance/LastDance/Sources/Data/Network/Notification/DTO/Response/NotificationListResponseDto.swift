//
//  NotificationListResponseDto.swift
//  LastDance
//
//  Created by 아우신얀 on 11/20/25.
//

import Foundation

// MARK: - NotificationListResponseDto
typealias NotificationListResponseDto = [NotificationItemDto]

// MARK: - NotificationItemDto
struct NotificationItemDto: Codable {
    let id: Int
    let notification_type: String
    let title: String
    let body: String
    let reaction_id: Int?
    let exhibition_id: Int?
    let artwork_id: Int?
    let visit_history_id: Int?
    let deep_link: String
    let is_read: Bool
    let is_sent: Bool
    let created_at: String
    let read_at: String?
}

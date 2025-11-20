//
//  NotificationItem.swift
//  LastDance
//
//  Created by 아우신얀 on 11/10/25.
//

import Foundation

struct NotificationItem: Identifiable {
    let id: Int
    let type: NotificationType
    let title: String
    let message: String
    let artworkId: Int
    let exhibitionId: Int
    let deepLink: String
    let isRead: Bool
    let createdAt: Date

    init(from dto: NotificationItemDto, userType: UserType) {
        self.id = dto.id
        self.type = userType == .artist ? .artist : .viewer
        self.title = dto.title
        self.message = dto.body
        self.artworkId = dto.artwork_id
        self.exhibitionId = dto.exhibition_id
        self.deepLink = dto.deep_link
        self.isRead = dto.is_read
        self.createdAt = Date.fromAPIServerString(dto.created_at) ?? Date()
    }

    var timeAgo: String {
        return createdAt.toTimeAgoString()
    }
}

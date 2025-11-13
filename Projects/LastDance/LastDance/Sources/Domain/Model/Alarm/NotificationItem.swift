//
//  NotificationItem.swift
//  LastDance
//
//  Created by 아우신얀 on 11/10/25.
//

import Foundation

struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotificationType
    let sender: String
    let message: String
    let timeAgo: String
}

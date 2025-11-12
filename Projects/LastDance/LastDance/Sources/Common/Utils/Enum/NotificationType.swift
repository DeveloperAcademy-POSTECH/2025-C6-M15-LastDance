//
//  NotificationType.swift
//  LastDance
//
//  Created by 아우신얀 on 11/10/25.
//

enum NotificationType {
    case artist
    case viewer

    var icon: String {
        switch self {
        case .artist: return "envelope.fill"  // 작가용
        case .viewer: return "heart.fill"  // 관람객용
        }
    }
}

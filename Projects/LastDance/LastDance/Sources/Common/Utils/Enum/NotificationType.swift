//
//  NotificationType.swift
//  LastDance
//
//  Created by 아우신얀 on 11/10/25.
//

enum NotificationType {
    case artist
    case viewer
    
    // TODO: 아이콘 수정 예정
    var icon: String {
        switch self {
        case .artist: return "paintbrush" // 작가용
        case .viewer: return "person.text.rectangle" // 관람객용
        }
    }
}

//
//  AlertType.swift
//  LastDance
//
//  Created by 아우신얀 on 10/20/25.
//

enum AlertType {
    case confirmation
    case error

    var image: String {
        switch self {
        case .confirmation: return "paperplane.circle"
        case .error: return "warning"
        }
    }

    var title: String {
        switch self {
        case .confirmation: return "메시지를 전송하시겠어요?"
        case .error: return "아쉬워요!"
        }
    }

    var message: String {
        switch self {
        case .confirmation: return "작가님에게 반응이 전달돼요."
        case .error: return "메시지 전송에 실패했어요."
        }
    }

    var buttonText: String {
        switch self {
        case .confirmation: return "확인"
        case .error: return "다시 보내기"
        }
    }
}

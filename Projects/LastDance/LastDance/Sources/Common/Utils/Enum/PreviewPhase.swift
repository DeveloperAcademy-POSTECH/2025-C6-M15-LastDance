//
//  PreviewPhase.swift
//  LastDance
//
//  Created by 배현진 on 11/8/25.
//

import CoreFoundation

/// 카메라 Preview 보여주는 상태 변경을 위한 enum
enum PreviewPhase: Int {
    case hidden      // 안보여줌
    case blurred     // 흐릿하게 보임
    case visible     // 안보임

    var blurRadius: CGFloat {
        switch self {
        case .hidden:  return 15
        case .blurred: return 8
        case .visible: return 0
        }
    }

    var opacity: Double {
        switch self {
        case .hidden:  return 0.0
        case .blurred: return 1.0
        case .visible: return 1.0
        }
    }

    var animationDuration: Double {
        switch self {
        case .hidden:  return 0.0
        case .blurred: return 0.45
        case .visible: return 0.45
        }
    }
}

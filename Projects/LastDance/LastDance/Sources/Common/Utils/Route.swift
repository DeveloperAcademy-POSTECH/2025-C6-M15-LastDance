//
//  Route.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import Foundation

/// 앱의 모든 화면 경로를 정의한 enum
enum Route: Hashable {
    case exhibitionList
    case exhibitionDetail(id: String)
    case camera
    case reaction
    case archive
    case category
    case completeReaction
}

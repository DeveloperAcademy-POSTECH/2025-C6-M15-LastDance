//
//  Constants.swift
//  LastDance
//
//  Created by 아우신얀 on 11/13/25.
//

import Foundation

// MARK: ReactionConstants
/// 반응(Reaction) 관련 상수
enum ReactionConstants {
    static let maxCategories: Int = 2
    static let maxTags: Int = 6
    static let maxMessageLength: Int = 500
    static let throttleInterval: TimeInterval = 2.0
    /// 카테고리 표시 제한 (토글 전)
    static let categoryDisplayLimit: Int = 4
    static let messagePlaceholder: String = "욕설, 비속어 사용 시 전송이 제한될 수 있습니다."
}

// MARK: CameraConstants
/// 카메라 관련 상수
enum CameraConstants {
    static let noticeVisibleDuration: Int = 2
    static let previewBlurDelay: Int = 400
    static let compressionQuality: CGFloat = 1.0
    static let zoomDragSensitivity: CGFloat = 200.0
    static let previewAspectRatio: CGFloat = 3.0 / 4.0

    /// 프리뷰 관련 카메라 설정
    static let cornerMarkLength: CGFloat = 22
    static let cornerMarkLineWidth: CGFloat = 3
    static let cornerMarkInset: CGFloat = 6

    /// 줌 관련 설정
    static let zoomRanges: [(label: String, min: CGFloat, max: CGFloat, preset: CGFloat)] = [
        (label: ".5", min: 0.0, max: 0.95, preset: 0.5),
        (label: "1", min: 0.95, max: 1.9, preset: 1.0),
        (label: "2", min: 1.9, max: .infinity, preset: 2.0),
    ]
    static let indicatorSpacing: CGFloat = 12
    static let indicatorPadding: CGFloat = 8
    static let indicatorBackgroundOpacity: CGFloat = 0.30
    static let animationDuration: CGFloat = 0.30
    static let circleInactiveDiameter: CGFloat = 34
    static let circleActiveDiameter: CGFloat = 44
}

// MARK: ArchiveImageConstants
/// 아카이브 이미지 크기 관련 상수
enum ArchiveImageConstants {
    static let minWidth: CGFloat = 300
    static let maxWidth: CGFloat = 345
    static let minHeight: CGFloat = 400
    static let maxHeight: CGFloat = 468
    static let animationThreshold: CGFloat = 100
    static let tabBarFixThreshold: CGFloat = 492
}

// MARK: ArchiveLayoutConstants
/// 아카이브 레이아웃 관련 상수
enum ArchiveLayoutConstants {
    static let rotationAngles: [Double] = [-4, 3, 3, -4]
}

// MARK: HTTPHeaderConstants
/// HTTP 헤더 상수
enum HTTPHeaderConstants {
    static let contentTypeJSON = "application/json"
}

// MARK: NetworkConstants
/// 네트워크 설정 상수
enum NetworkConstants {
    static let baseURLKey = "BASE_URL"
}

// MARK: NetworkErrorMessages
/// 네트워크 에러 메시지 상수
enum NetworkErrorMessages {
    static let badRequest = "잘못된 요청입니다."
    static let notFound = "요청한 데이터를 찾을 수 없습니다."
    static let decodingFailed = "데이터를 파싱에 실패했습니다."
    static let networkFailure = "네트워크 연결을 확인해주세요."
    static let serverError = "서버 에러가 발생했습니다."
}

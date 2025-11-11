//
//  AppClipRoute.swift
//  LastDance
//
//  Created by 배현진 on 11/10/25.
//

import Foundation

/// App Clip에서만 쓸 라우트
enum ClipRoute: Hashable {
    /// 작품 상세 + 반응 남기기
    case artworkDetail(artworkId: Int, exhibitionId: Int)

    /// 전송 완료 화면 정도가 필요하면 이렇게 추가
    case complete
}

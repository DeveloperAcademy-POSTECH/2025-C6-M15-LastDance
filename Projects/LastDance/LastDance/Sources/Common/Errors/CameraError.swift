//
//  CameraError.swift
//  LastDance
//
//  Created by 배현진 on 10/15/25.
//

import Foundation

public enum CameraError: Error, LocalizedError {
    case unauthorized  // 권한 거부/미승인
    case configurationFailed  // 세션/입력/출력 구성 실패
    case captureFailed  // 촬영/프레임 추출 실패

    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "카메라 권한이 필요합니다. 설정에서 허용해주세요."
        case .configurationFailed:
            return "카메라 구성을 완료하지 못했습니다."
        case .captureFailed:
            return "촬영에 실패했습니다."
        }
    }
}

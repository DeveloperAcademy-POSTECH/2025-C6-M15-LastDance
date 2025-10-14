//
//  CameraViewModel.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import AVFoundation
import SwiftUI

@MainActor
final class CameraViewModel: ObservableObject {
    @Published var isAuthorized = false
    @Published var isRunning = false
    @Published var capturedImage: UIImage?
    @Published var croppedForDisplay: UIImage?
    @Published var errorMessage: String?
    @Published var zoomScale: CGFloat = 1.0

    let manager = CameraManager()

    func prepare() async {
        switch CameraManager.checkAuthorizationStatus() {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = await CameraManager.requestAccess()
        default:
            isAuthorized = false
        }

        guard isAuthorized else {
            errorMessage = "카메라 권한이 필요합니다. 설정에서 허용해주세요."
            return
        }

        do {
            try await manager.configureIfNeeded()
            start()
        } catch {
            errorMessage = "카메라 설정에 실패했습니다."
        }
    }

    func start() {
        manager.startRunning()
        isRunning = true
    }

    func stop() {
        manager.stopRunning()
        isRunning = false
    }

    func capture() async {
        if let image = await manager.captureSilent() {
            self.capturedImage = image
        } else {
            self.errorMessage = "무음 촬영 실패"
        }
    }
}

// MARK: - Zoom
extension CameraViewModel {
    /// 장치 기반 실제 허용 범위를 UI 스케일로 반영
    var minZoomScale: CGFloat {
        // 보통 0.5
        manager.zoomBounds().min
    }
    var maxZoomScale: CGFloat {
        // 기기에 따라 6.0 근방
        manager.zoomBounds().max
    }

    /// 프리셋/슬라이더/드래그 공용 진입점
    func selectZoomScale(_ scale: CGFloat, animated: Bool = true) {
        let clamped = max(minZoomScale, min(maxZoomScale, scale))
        zoomScale = clamped
        manager.setZoomScale(clamped, animated: animated)
    }

    /// 드래그 종료 시 깔끔히 램프 종료
    func endZoomInteraction() {
        manager.cancelZoomRampIfNeeded()
    }
}

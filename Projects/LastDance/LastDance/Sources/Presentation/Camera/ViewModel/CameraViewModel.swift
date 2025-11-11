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
    @Published var showSilentNotice = false
    @Published var previewPhase: PreviewPhase = .hidden

    private(set) var hasShownSilentNotice = false
    private var hideNoticeTask: Task<Void, Never>?

    let manager = CameraManager()

    func setupCameraSession() async {
        previewPhase = .hidden
        do {
            try await requestCameraAuthorization()
            try await configureCaptureSession()
            
            manager.onFirstFrame = { [weak self] in
                guard let self else { return }
                self.previewPhase = .blurred
                Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    self.previewPhase = .visible
                }
            }
            
            await startSession()
            
            if !hasShownSilentNotice {
                hasShownSilentNotice = true
                showSilentNoticeTemporarily()
            }
        } catch {
            handleCameraError(error)
        }
    }

    /// 카메라 세션 시작
    func startSession() async {
        manager.startRunning()
        isRunning = true
    }

    /// 카메라 세션 중지
    func stopSession() {
        manager.stopRunning()
        isRunning = false
        
        hideNoticeTask?.cancel()
        hideNoticeTask = nil
        showSilentNotice = false
    }

    /// 무음(비디오 프레임 스냅샷) 촬영
    func captureSilentFrame() async {
        if let image = await manager.captureSilent() {
            self.capturedImage = image
        } else {
            self.errorMessage = "무음 촬영 실패"
        }
    }
    
    /// 카메라 권한을 요청합니다.
    func requestCameraAuthorization() async throws {
        switch CameraManager.checkAuthorizationStatus() {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = await CameraManager.requestAccess()
        default:
            isAuthorized = false
        }

        guard isAuthorized else {
            throw CameraError.unauthorized
        }
    }

    /// 권한 승인 후 세션을 구성합니다.
    func configureCaptureSession() async throws {
        do {
            try await manager.configureIfNeeded(initialZoomScale: zoomScale)
        } catch {
            throw CameraError.configurationFailed
        }
    }
    
    /// 카메라 공통 에러 처리
    func handleCameraError(_ error: Error) {
        if let cameraError = error as? CameraError {
            errorMessage = cameraError.localizedDescription
        } else {
            errorMessage = "알 수 없는 오류가 발생했습니다."
        }
    }
    
    // 무음촬영모드임을 알리는 애니메이션
    private func showSilentNoticeTemporarily(visibleFor: Duration = .seconds(2)) {
        showSilentNotice = true
        hideNoticeTask?.cancel()
        
        hideNoticeTask = Task { [weak self] in
            do {
                try await Task.sleep(for: visibleFor)
            } catch { return } // 취소됨
            await MainActor.run { [weak self] in
                self?.showSilentNotice = false
            }
        }
    }
    
    deinit {
        hideNoticeTask?.cancel()
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

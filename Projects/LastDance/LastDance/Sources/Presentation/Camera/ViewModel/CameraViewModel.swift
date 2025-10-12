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
        do {
            let image = try await manager.capturePhoto()
            capturedImage = image
            let cropped = image.cropped(toAspect: CameraViewLayout.aspect)
            self.croppedForDisplay = cropped
        } catch {
            errorMessage = "촬영에 실패했습니다."
        }
    }
}

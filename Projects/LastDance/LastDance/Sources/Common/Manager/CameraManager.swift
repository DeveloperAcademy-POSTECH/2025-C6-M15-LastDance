//
//  CameraManager.swift
//  LastDance
//
//  Created by 배현진 on 10/08/25.
//

import AVFoundation
import UIKit

final class CameraManager: NSObject, @unchecked Sendable {
    let session = AVCaptureSession()
    var onFirstFrame: (() -> Void)?

    private var didSendFirstFrame = false
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()

    private(set) var isConfigured = false
    private var photoProcessors: [Int64: PhotoCaptureProcessor] = [:]
    
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "camera.video.queue")
    private(set) var lastVideoBuffer: CMSampleBuffer?

    // MARK: - Permission
    static func checkAuthorizationStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    static func requestAccess() async -> Bool {
        await withCheckedContinuation { cont in
            AVCaptureDevice.requestAccess(for: .video) { cont.resume(returning: $0) }
        }
    }

    // MARK: - Configure (rear-only)
    func configureIfNeeded(initialZoomScale: CGFloat? = nil) async throws {
        guard !isConfigured else { return }
        guard Self.checkAuthorizationStatus() == .authorized else {
            throw CameraManagerError.unauthorized
        }

        try await withCheckedThrowingContinuation { cont in
            sessionQueue.async { [self] in
                do {
                    self.session.beginConfiguration()
                    self.session.sessionPreset = .photo

                    // 후면 카메라만 사용
                    guard let device = Self.bestDevice(position: .back),
                          let input = try? AVCaptureDeviceInput(device: device)
                    else { throw CameraManagerError.configurationFailed }

                    if self.session.canAddInput(input) { self.session.addInput(input) }
                    self.videoDeviceInput = input

                    // 초기 줌 값 적용
                    if let initialZoomScale {
                        // UI 스케일을 디바이스 줌으로 변환
                        let targetZoomFactor = self.deviceZoomFactor(fromUIScale: initialZoomScale)
                        do {
                            try device.lockForConfiguration()
                            let clamped = max(
                                device.minAvailableVideoZoomFactor,
                                min(targetZoomFactor,
                                    device.maxAvailableVideoZoomFactor)
                            )
                            device.videoZoomFactor = clamped
                            device.unlockForConfiguration()
                        } catch {
                            Log.error("initial zoom set failed: \(error)")
                        }
                    }
                    
                    if self.session.canAddOutput(self.photoOutput) {
                        self.session.addOutput(self.photoOutput)

                        if #unavailable(iOS 16.0) {
                            // iOS 15 이하: isHighResolutionPhotoEnabled 사용
                            self.photoOutput.isHighResolutionCaptureEnabled = true
                        } else {
                            // iOS 16 이상: maxPhotoDimensions 사용
                            if let device = self.videoDeviceInput?.device {
                                let dims = CMVideoFormatDescriptionGetDimensions(
                                    device.activeFormat.formatDescription
                                )
                                self.photoOutput.maxPhotoDimensions = CMVideoDimensions(
                                    width: dims.width,
                                    height: dims.height
                                )
                            }
                        }
                    }
                    
                    // 무음 스냅샷용 비디오 데이터
                    self.videoOutput.alwaysDiscardsLateVideoFrames = true
                    self.videoOutput.setSampleBufferDelegate(self, queue: self.videoQueue)
                    if self.session.canAddOutput(self.videoOutput) {
                        self.session.addOutput(self.videoOutput)
                    }
                    self.videoOutput.connection(with: .video)?.videoRotationAngle = 0.0

                    self.session.commitConfiguration()
                    self.isConfigured = true
                    cont.resume()
                } catch {
                    self.session.commitConfiguration()
                    cont.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Start/Stop
    func startRunning() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.didSendFirstFrame = false
                self.session.startRunning()
            }
        }
    }
    
    func stopRunning() {
        sessionQueue.async { if self.session.isRunning { self.session.stopRunning() } }
    }

    // MARK: - Capture
    func capturePhoto() async throws -> UIImage {
        try await withCheckedThrowingContinuation { cont in
            let settings = AVCapturePhotoSettings()
            
            if #unavailable(iOS 16.0) {
                // iOS 15 이하: isHighResolutionPhotoEnabled 사용
                settings.isHighResolutionPhotoEnabled =
                    self.photoOutput.isHighResolutionCaptureEnabled
            }
            // iOS 16 이상: maxPhotoDimensions 자동 반영됨
            
            let id = settings.uniqueID
            
            let processor = PhotoCaptureProcessor(id: id) { [weak self] result in
                guard let self else { return }
                // 메모리 해제
                self.photoProcessors[id] = nil

                switch result {
                case .success(let image):
                    cont.resume(returning: image)
                case .failure(let error):
                    cont.resume(throwing: error)
                }
            }
            
            self.photoProcessors[id] = processor
            self.photoOutput.capturePhoto(with: settings, delegate: processor)
        }
    }
    
    // 무음 촬영 메서드 추가
    func captureSilent() async -> UIImage? {
        await withCheckedContinuation { continuation in
            videoQueue.async {
                guard let buffer = self.lastVideoBuffer,
                      let img = UIImage.from(sampleBuffer: buffer, orientation: .right) else {
                    DispatchQueue.main.async { continuation.resume(returning: nil) }
                    return
                }
                DispatchQueue.main.async { continuation.resume(returning: img) }
            }
        }
    }

    // MARK: - Helpers
    private static func bestDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let preferredOrders: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera
        ]

        for type in preferredOrders {
            let discovery = AVCaptureDevice.DiscoverySession(
                deviceTypes: [type],
                mediaType: .video,
                position: position
            )
            if let device = discovery.devices.first { return device }
        }
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }
}

// MARK: - 사진 촬영을 위한 delegate
private final class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    let id: Int64
    private let completion: (Result<UIImage, Error>) -> Void
    private var didFinish = false

    init(id: Int64, completion: @escaping (Result<UIImage, Error>) -> Void) {
        self.id = id
        self.completion = completion
    }

    private func finish(_ result: Result<UIImage, Error>) {
        guard !didFinish else { return }
        didFinish = true
        completion(result)
    }

    // 사진 처리 콜백
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            finish(.failure(error))
            return
        }
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            finish(.failure(CameraManagerError.captureFailed))
            return
        }
        finish(.success(image))
    }

    // 콜백이 오지 않는 드문 경우를 대비
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        if let error = error {
            finish(.failure(error))
            return
        }
        
        if !didFinish {
            finish(.failure(CameraManagerError.captureFailed))
        }
    }
}

// MARK: - 영상 촬영을 위한 delegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        lastVideoBuffer = sampleBuffer
        
        if !didSendFirstFrame {
            didSendFirstFrame = true
            DispatchQueue.main.async { [weak self] in
                self?.onFirstFrame?()
            }
        }
    }
}

// MARK: - Zoom
extension CameraManager {
    /// UI에서 쓰는 스케일(0.5~6.0)을 장치 팩터로 매핑할 때 쓰는 계수
    private var uiToDeviceFactor: CGFloat { 2.0 }

    /// 장치가 지원하는 줌 범위를 UI 스케일(=device/uiToDeviceFactor)로 반환
    func zoomBounds() -> (min: CGFloat, max: CGFloat) {
        guard let device = videoDeviceInput?.device else { return (1.0, 1.0) }
        // 가상 멀티카메라로 끊김 없이 렌즈 스위치
        let minUI = max(0.5, device.minAvailableVideoZoomFactor / uiToDeviceFactor)
        let maxUI = min(6.0, device.maxAvailableVideoZoomFactor / uiToDeviceFactor)
        return (minUI, maxUI)
    }

    /// 스무스한 줌 동작
    func setZoomScale(_ uiScale: CGFloat, animated: Bool = true, rate: Float = 12.0) {
        guard let device = videoDeviceInput?.device else { return }

        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            // 장치 범위로 클램프
            let minF = device.minAvailableVideoZoomFactor
            let maxF = device.maxAvailableVideoZoomFactor

            let targetFactor = max(minF, min(uiScale * uiToDeviceFactor, maxF))

            // 불필요한 호출 억제
            if abs(device.videoZoomFactor - targetFactor) < 0.003 { return }

            if animated {
                if device.isRampingVideoZoom { device.cancelVideoZoomRamp() }
                device.ramp(toVideoZoomFactor: targetFactor, withRate: rate)
            } else {
                device.videoZoomFactor = targetFactor
            }
        } catch {
            Log.error("setZoomScale 실패: \(error)")
        }
    }

    /// 드래그 종료 시 호출(램프 중지)
    func cancelZoomRampIfNeeded() {
        guard let device = videoDeviceInput?.device else { return }
        do {
            try device.lockForConfiguration()
            if device.isRampingVideoZoom { device.cancelVideoZoomRamp() }
            device.unlockForConfiguration()
        } catch { }
    }
    
    /// UI 스케일을 디바이스 실제 줌팩터로 변환
    fileprivate func deviceZoomFactor(fromUIScale uiScale: CGFloat) -> CGFloat {
        uiScale * uiToDeviceFactor
    }
}

private enum CameraManagerError: Error {
    case unauthorized
    case configurationFailed
    case captureFailed
}

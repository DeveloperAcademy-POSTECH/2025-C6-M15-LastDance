//
//  CameraPreviewView.swift
//  LastDance
//
//  Created by 배현진 on 10/08/25.
//

import AVFoundation
import SwiftUI

struct CameraPreviewView: UIViewRepresentable {
  let session: AVCaptureSession

  let currentScaleProvider: () -> CGFloat  // 현재 UI 스케일(예: viewModel.zoomScale)
  let applyScale: (_ newScale: CGFloat, _ animated: Bool) -> Void
  let endInteraction: () -> Void

  func makeUIView(context: Context) -> PreviewUIView {
    let view = PreviewUIView()
    view.videoPreviewLayer.session = session

    view.currentScaleProvider = currentScaleProvider
    view.applyScale = applyScale
    view.endInteraction = endInteraction

    return view
  }

  func updateUIView(_ uiView: PreviewUIView, context: Context) {
    // SwiftUI가 레이아웃을 갱신할 때마다 layer의 frame을 갱신
    uiView.videoPreviewLayer.frame = uiView.bounds
    uiView.currentScaleProvider = currentScaleProvider
    uiView.applyScale = applyScale
    uiView.endInteraction = endInteraction
  }
}

final class PreviewUIView: UIView {
  override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    return layer as! AVCaptureVideoPreviewLayer
  }

  var currentScaleProvider: (() -> CGFloat)?
  var applyScale: ((CGFloat, Bool) -> Void)?
  var endInteraction: (() -> Void)?

  // 내부 상태
  private var pinchStartScale: CGFloat = 1.0

  override init(frame: CGRect) {
    super.init(frame: frame)
    isUserInteractionEnabled = true
    videoPreviewLayer.videoGravity = .resizeAspectFill

    // ✅ 핀치 제스처 등록
    let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
    pinchRecognizer.cancelsTouchesInView = false
    addGestureRecognizer(pinchRecognizer)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    videoPreviewLayer.frame = bounds
  }

  @objc private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
    switch recognizer.state {
    case .began:
      // 현재 스케일을 기준점으로
      pinchStartScale = currentScaleProvider?() ?? 1.0
    case .changed:
      // 누적 배율 → 시작스케일 × 핀치배율
      let nextScale = pinchStartScale * recognizer.scale
      applyScale?(nextScale, true)  // animated=true로 부드럽게
    case .ended, .cancelled, .failed:
      endInteraction?()  // 램프 정리 등
    default:
      break
    }
  }
}

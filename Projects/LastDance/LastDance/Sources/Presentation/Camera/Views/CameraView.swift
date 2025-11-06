//
//  CameraView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import AVFoundation
import SwiftUI

struct CameraView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = CameraViewModel()
    
    @State private var noticeVisible = false
    
    let exhibitionId: Int

    var body: some View {
        GeometryReader { geo in
            let maxPreviewHeight = max(1, geo.size.height - (
                CameraViewLayout.previewTopInset + CameraViewLayout.previewBottomInset)
            )
            let maxPreviewWidth = max(1, geo.size.width)

            ZStack {
                Color.black.ignoresSafeArea()

                Preview(
                    viewModel: viewModel,
                    maxWidth: maxPreviewWidth,
                    maxHeight: maxPreviewHeight
                )

                BottomControllerView(viewModel: viewModel)
                
                if noticeVisible {
                    VStack {
                        HStack(spacing: 12) {
                            Image("camera_warning")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 26, height: 26)

                            Text("카메라 소리가 나지 않으니 안심하세요!")
                                .font(LDFont.medium04)
                                .foregroundStyle(LDColor.color6)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(LDColor.color1)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .cornerRadius(12)
                        .shadow(LDShadow.shadow4)
                        .shadow(LDShadow.shadow5)
                        .shadow(LDShadow.shadow6)
                        
                        Spacer()
                    }
                    .padding(.top, 73)
                    .zIndex(2)
                }
            }
            .overlay(alignment: .topLeading) {
                CloseButton {
                    router.popLast()
                }
                .padding(.top, 12)
                .padding(.leading, 12)
            }
        }
        .task { await viewModel.setupCameraSession() }
        .onChange(of: viewModel.capturedImage) { _, newImage in
            if let image = newImage, let imageData = image.jpegData(compressionQuality: 1.0) {
                router.push(.captureConfirm(imageData: imageData, exhibitionId: exhibitionId))
                viewModel.capturedImage = nil
            }
        }
        .onChange(of: viewModel.showSilentNotice) { _, newValue in
            withAnimation(.easeInOut(duration: newValue ? 0.3 : 0.5)) {
                noticeVisible = newValue
            }
        }
        .onAppear {
            // 초기 동기화 (필요 시)
            noticeVisible = viewModel.showSilentNotice
        }
        .onDisappear { viewModel.stopSession() }
    }
}

private struct Preview: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var maxWidth: CGFloat?
    var maxHeight: CGFloat?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: CameraViewLayout.previewTopInset)
            
            Group {
                if viewModel.isAuthorized {
                    CameraPreviewView(
                        session: viewModel.manager.session,
                        currentScaleProvider: { viewModel.zoomScale },
                        applyScale: { newScale, animated in
                            viewModel.selectZoomScale(newScale, animated: animated)
                        },
                        endInteraction: {
                            viewModel.endZoomInteraction()
                        }
                    )
                    .viewfinderCorners(length: 21, lineWidth: 3, color: LDColor.color6, inset: 2)
                } else {
                    Color.black
                        .overlay(
                            Text("카메라 권한 필요")
                                .foregroundStyle(LDColor.color6.opacity(0.6))
                                .font(.callout)
                        )
                }
            }
            .aspectRatio(CameraViewLayout.aspect, contentMode: .fit)
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(LDColor.color6.opacity(0.06), lineWidth: 1)
            )

            Spacer(minLength: CameraViewLayout.previewBottomInset)
        }
    }
}

private struct CloseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(LDColor.color6)
                .frame(width: 28, height: 28)
                .padding(8)
        }
        .contentShape(Circle())
        .accessibilityLabel(Text("닫기"))
    }
}

// MARK: - Constants
enum CameraViewLayout {
    /// 스틸 기본 4:3 (세로 기준 3:4)
    static let aspect: CGFloat = 3.0 / 4.0
    /// 프리뷰 위 여백
    static let previewTopInset: CGFloat = 24
    /// 프리뷰 아래 여백
    static let previewBottomInset: CGFloat = 70
    /// Confirm에서 프리뷰보다 더 작은 카드 폭 비율
    static let confirmCardWidthRatio: CGFloat = 0.90
}

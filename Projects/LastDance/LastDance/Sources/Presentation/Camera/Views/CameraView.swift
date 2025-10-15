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
    
    @State private var showConfirm = false
    @State private var noticeVisible = false

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
                        HStack {
                            Image(systemName: "speaker.slash.fill")
                                .foregroundStyle(.black)
                            Text("카메라 소리가 나지 않으니 안심하세요!")
                                .font(.subheadline)
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.white)
                        .clipShape(Capsule())
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    .padding(.top, 40)
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
        .onChange(of: viewModel.capturedImage) { _, new in
            showConfirm = (new != nil)
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
        // TODO: - 촬영 확인 화면 띄우는 방식에 따라 수정
        .fullScreenCover(isPresented: $showConfirm) {
            if let image = viewModel.capturedImage {
                CaptureConfirmView(
                    image: image,
                    onUse: { _ in
                        // TODO: 작품 인식시키거나 정보 입력으로 연결
                        // 임시: 카메라 닫기
                        router.popLast()
                    },
                    onRetake: {
                        showConfirm = false
                    }
                )
            } else {
                // 예외적으로 nil이면 그냥 닫기
                Color.black.ignoresSafeArea().onAppear { showConfirm = false }
            }
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
                    .viewfinderCorners(length: 21, lineWidth: 3, color: .white, inset: 2)
                } else {
                    Color.black
                        .overlay(
                            Text("카메라 권한 필요")
                                .foregroundStyle(.white.opacity(0.6))
                                .font(.callout)
                        )
                }
            }
            .aspectRatio(CameraViewLayout.aspect, contentMode: .fit)
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
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
                .foregroundColor(.white)
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

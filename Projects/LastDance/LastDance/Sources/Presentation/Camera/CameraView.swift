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

    var body: some View {
        GeometryReader { geo in
            let maxPreviewHeight = max(1, geo.size.height - (
                CameraViewLayout.previewTopInset + CameraViewLayout.previewBottomInset)
            )
            let maxPreviewWidth = max(1, geo.size.width)

            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: CameraViewLayout.previewTopInset)
                    
                    Group {
                        if viewModel.isAuthorized {
                            CameraPreviewView(session: viewModel.manager.session)
                        } else {
                            Color.black
                                .overlay(
                                    Text("카메라 권한 필요")
                                        .foregroundStyle(.white.opacity(0.6))
                                        .font(.callout)
                                )
                        }
                    }
                    .aspectRatio(CameraViewLayout.aspect, contentMode: .fit)  // 3:4 박스 유지
                    .frame(maxWidth: maxPreviewWidth, maxHeight: maxPreviewHeight) // 최대치만 제한
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )

                    Spacer(minLength: CameraViewLayout.previewBottomInset)
                }

                VStack {
                    Spacer()
                    ShutterButton {
                        Task { await viewModel.capture() }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .task { await viewModel.prepare() }
        .onDisappear { viewModel.stop() }
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
}

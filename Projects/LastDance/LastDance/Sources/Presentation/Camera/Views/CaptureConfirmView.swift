//
//  CaptureConfirmView.swift
//  LastDance
//
//  Created by 배현진 on 10/10/25.
//

import SwiftUI

struct CaptureConfirmView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = CaptureConfirmViewModel()

    let imageData: Data
    let exhibitionId: Int

    private var image: UIImage? {
        UIImage(data: imageData)
    }

    var body: some View {
        // 버튼 높이를 계산하기 위한 GeometryReader
        GeometryReader { geo in
            let safeBottom = geo.safeAreaInsets.bottom

            // 버튼 높이 계산
            let buttonsBlockHeight: CGFloat = 82 + 24 + safeBottom

            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                if let image = image {
                    // 화면 비율의 유연성을 위한 ScrollView 추가
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 0) {

                            Spacer(minLength: 45)

                            // 이미지 영역
                            matchedImageView
                                .frame(width: geo.size.width)
                                .clipped()

                            Spacer(minLength: 34)

                            ZStack {
                                Button {
                                    viewModel.uploadImage(image)

                                    let displayImage = viewModel.matchedArtworkImage ?? image

                                    // TODO: - 연결 플로우 변경
                                    router.push(
                                        .inputArtworkInfo(
                                            image: displayImage, exhibitionId: exhibitionId,
                                            artistId: nil)
                                    )
                                } label: {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(LDColor.color6)
                                        .padding(8)
                                        .frame(width: 82, height: 82)
                                        .background(LDColor.color1, in: Circle())
                                }
                                .disabled(viewModel.isMatching)

                                Button {
                                    router.popLast()
                                } label: {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(LDColor.black2)
                                        .padding(8)
                                        .frame(width: 52, height: 52)
                                        .background(LDColor.gray3, in: Circle())
                                }
                                .offset(x: 100)
                            }

                            Color.clear.frame(height: safeBottom)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .ignoresSafeArea(.all, edges: .bottom)

                } else {
                    Text("이미지를 불러올 수 없습니다.")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // 매칭 중일때 보여줄 내용
                // TODO: - 디자인팀 의견 나오면 반영
                if viewModel.isMatching {
                    ProgressView()
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                        )
                }
            }
        }
        .onAppear {
            // 화면 진입 시점에 바로 서버 이미지 매칭 시작
            viewModel.matchArtwork(
                imageData: imageData,
                exhibitionIdFilter: exhibitionId,
                threshold: 0.4
            )
        }
        .customAlert(
            isPresented: $viewModel.showFailAlert,
            image: "warning",
            title: "인식 실패",
            message: "작품을 찾을 수 없습니다.",
            buttonText: "다시 촬영하기"
        ) {
            router.popLast()
        }
        .toolbar {
            CustomNavigationBar(title: "") {
                router.popLast()
            }
        }
    }

    @ViewBuilder
    private var matchedImageView: some View {
        if let artworkImage = viewModel.matchedArtworkImage {
            Image(uiImage: artworkImage)
                .resizable()
                .scaledToFit()
        } else if let candidate = viewModel.topCandidate,
            let urlString = candidate.thumbnail_url
        {
            CachedImage(urlString)
                .scaledToFit()
        } else if let image = image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Color.black
        }
    }
}

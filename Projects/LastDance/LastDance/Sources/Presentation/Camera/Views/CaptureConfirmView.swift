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

    @State private var saveNoticeVisible = false

    private var image: UIImage? {
        UIImage(data: imageData)
    }

    var body: some View {
        // 버튼 높이를 계산하기 위한 GeometryReader
        GeometryReader { geo in
            let safeBottom = geo.safeAreaInsets.bottom

            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                if let image = image {
                    VStack(spacing: 0) {
                        // 작품 인식이 완료되면 텍스트 표시
                        if viewModel.showMatchConfirmAlert {
                            Spacer().frame(height: 9)

                            Text("촬영한 작품이 맞나요?")
                                .foregroundStyle(LDColor.color1)
                                .font(LDFont.heading04)

                            Spacer().frame(height: 12)
                        } else {
                            Spacer().frame(height: 45)
                        }

                        // 스크롤 가능한 이미지 영역
                        ScrollView(.vertical, showsIndicators: false) {
                            ZStack {
                                matchedImageView
                                    .frame(width: geo.size.width)
                                    .clipped()

                                // 작품 인식이 완료되면 이미지 하단에 카드 표시
                                if viewModel.showMatchConfirmAlert, let artwork = viewModel.artwork
                                {
                                    VStack {
                                        Spacer()
                                        ArtworkMatchCardView(
                                            artwork: artwork, artist: viewModel.artist
                                        )
                                        .padding(.bottom, 24)
                                        .padding(.horizontal, 24)
                                    }
                                }
                            }
                        }

                        Spacer().frame(height: 34)

                        // 고정된 하단 버튼
                        ZStack {
                            Button {
                                // TODO: - 쇼케이스 위한 전시Id 지정. 이후에 변경 필요
                                guard
                                    let artworkId = viewModel.matchedArtworkId,
                                    let artistId = viewModel.matchedArtistId,
                                    let exhibition = viewModel.matchedExhibitions.first
                                else {
                                    return
                                }

                                handleStartVisit(
                                    image: image,
                                    artworkId: artworkId,
                                    artistId: artistId,
                                    exhibitionId: exhibition.id
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
                        .padding(.bottom, safeBottom > 0 ? safeBottom : 24)
                    }

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

                // 저장 완료 알림
                if saveNoticeVisible {
                    VStack {
                        HStack(spacing: 8) {
                            Image("CheckIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)

                            Text("이미지가 갤러리에 저장되었습니다.")
                                .font(LDFont.medium04)
                                .foregroundStyle(LDColor.color1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .cornerRadius(12)
                        .shadow(LDShadow.shadow4)
                        .shadow(LDShadow.shadow5)
                        .shadow(LDShadow.shadow6)
                        .offset(y: 28)

                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            if let image = image {
                viewModel.saveImageToPhotoLibrary(image: image)
            }

            // 화면 진입 시점에 바로 서버 이미지 매칭 시작
            viewModel.matchArtwork(
                imageData: imageData,
                threshold: 0.4
            )

            // 2초 동안 저장 완료 팝업 표시
            withAnimation(.easeInOut(duration: 0.3)) {
                saveNoticeVisible = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    saveNoticeVisible = false
                }
            }
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
    /// 관람객 - 관람 시작하기 버튼 처리
    private func handleStartVisit(image: UIImage, artworkId: Int, artistId: Int, exhibitionId: Int)
    {
        viewModel.uploadImage(image)
        viewModel.fetchArtistDetail(artistId: artistId)
        viewModel.fetchArtworkDetail(artworkId: artworkId, exhibitionId: exhibitionId)
        viewModel.createVisitHistory { success in
            if success {
                viewModel.selectExhibitionAsUserExhibition()

                guard let artist = viewModel.artist, let artwork = viewModel.artwork else {
                    return Log.error("Failed to fetch artist or artwork.")
                }
                router.push(
                    .artReactionSend(
                        artwork: artwork,
                        artist: artist,
                        exhibitionId: exhibitionId,
                        imageData: imageData
                    )
                )
            } else {
                Log.error("Failed to create visit history.")
            }
        }
    }
}

// MARK: ArtworkMatchCardView
struct ArtworkMatchCardView: View {
    let artwork: Artwork
    let artist: Artist?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            //사진
            CachedImage(artwork.thumbnailURL)
                .aspectRatio(contentMode: .fill)
                .frame(width: 52, height: 71)
                .cornerRadius(8)
                .clipped()

            //정보
            VStack(alignment: .leading, spacing: 12) {
                Text(artwork.title)
                    .font(LDFont.heading04)
                    .foregroundColor(LDColor.color1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let artistName = artist?.name {
                    HStack {
                        Text(artistName)
                            .font(LDFont.medium05)
                            .foregroundColor(LDColor.color1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .inset(by: 0.5)
                            .stroke(LDColor.color1, lineWidth: 1)
                    )
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: 95)
        .background(.white.opacity(0.6))
        .cornerRadius(13)
        .shadow(color: .black.opacity(0.14), radius: 5, x: 0, y: 0)
    }
}

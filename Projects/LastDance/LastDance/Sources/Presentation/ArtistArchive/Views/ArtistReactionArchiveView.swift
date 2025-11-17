//
//  ArtistReactionArchiveView.swift
//  LastDance
//
//  Created by 광로 on 10/14/25.
//

import SwiftData
import SwiftUI
import SwiftUIMasonry

struct ArtistReactionArchiveView: View {
    let exhibitionId: Int
    @StateObject private var viewModel: ArtistReactionArchiveViewModel
    @EnvironmentObject private var router: NavigationRouter

    init(exhibitionId: Int) {
        self.exhibitionId = exhibitionId
        _viewModel = StateObject(
            wrappedValue: ArtistReactionArchiveViewModel(exhibitionId: exhibitionId))
    }

    var body: some View {
        VStack(spacing: 0) {
            ArtistArtworkScrollView(viewModel: viewModel)
        }
        .toolbar {
            CustomNavigationBar(title: "\(viewModel.exhibitionTitle)") {
                router.popLast()
            }
        }
        .background(LDColor.color6)
        .onAppear {
            viewModel.loadArtworksAndReactions()
        }
    }
}

private struct ArtistArtworkScrollView: View {
    @ObservedObject var viewModel: ArtistReactionArchiveViewModel
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                // 로딩 상태
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, minHeight: 400)
            } else {
                // 작품 목록 그리드
                VMasonry(columns: 2, spacing: 19) {
                    ForEach(viewModel.artworks) { displayItem in
                        VStack(alignment: .leading, spacing: 4) {
                            // 작품 카드 이미지
                            ZStack(alignment: .bottomLeading) {
                                CachedImage(displayItem.artwork.thumbnailURL)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                // 반응 카운터 배지
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text("\(displayItem.reactionCount)")
                                            .font(LDFont.regular03)
                                            .foregroundColor(LDColor.color6)
                                    )
                                    .padding(.leading, 12)
                                    .padding(.bottom, 12)
                            }

                            Spacer().frame(height: 4)

                            // 작품 제목
                            Text(displayItem.artwork.title)
                                .font(LDFont.heading04)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // 작가 이름
                            if let artist = viewModel.artist(for: displayItem.artwork) {
                                Text(artist.name)
                                    .font(LDFont.regular02)
                                    .foregroundColor(LDColor.color2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .onTapGesture {
                            router.push(.response(artworkId: displayItem.artwork.id))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

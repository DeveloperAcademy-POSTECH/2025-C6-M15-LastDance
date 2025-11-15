//
//  ArtistReactionArchiveView.swift
//  LastDance
//
//  Created by 광로 on 10/14/25.
//

import SwiftData
import SwiftUI

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
        ArtistArtworkScrollView(viewModel: viewModel)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                CustomNavigationBar(title: viewModel.exhibitionTitle) {
                    router.popLast()
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
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
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(155), spacing: 27),
                        GridItem(.fixed(155), spacing: 27),
                    ],
                    spacing: 28
                ) {
                    ForEach(viewModel.artworks) { displayItem in
                        VStack(alignment: .leading, spacing: 12) {
                            ArtworkThumbnailView(
                                thumbnailURL: displayItem.artwork.thumbnailURL,
                                width: 155,
                                height: 219,
                                cornerRadius: 0
                            )

                            Text(displayItem.artwork.title)
                                .font(LDFont.heading06)
                                .foregroundColor(.black)
                                .frame(width: 155, alignment: .leading)
                        }
                        .onTapGesture {
                            router.push(.response(artworkId: displayItem.artwork.id))
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

//
//  ExhibitionArchiveView.swift
//  LastDance
//
//  Created by 광로 on 10/14/25.
//

import SwiftData
import SwiftUI

/// 관람객 플로우 - 내가 다녀온 전시 목록에서 전시 하나 선택했을때 보여주는 작품 목록 뷰
struct ExhibitionArchiveView: View {
    @StateObject private var viewModel: ExhibitionArchiveViewModel
    @EnvironmentObject private var router: NavigationRouter
    @Query private var exhibitions: [Exhibition]

    private var exhibition: Exhibition? {
        exhibitions.first
    }

    init(exhibitionId: Int) {
        _viewModel = StateObject(
            wrappedValue: ExhibitionArchiveViewModel(
                exhibitionId: exhibitionId
            ))

        // 해당 id에 맞는 Exhibition 정보만 가져옴
        _exhibitions = Query(
            filter: #Predicate<Exhibition> { exhibition in
                exhibition.id == exhibitionId
            })
    }

    var body: some View {
        VStack(spacing: 0) {
            // 전시 정보 헤더
            VStack(alignment: .leading, spacing: 8) {
                // 전시 제목
                Text(exhibition?.title ?? "전시 정보 로딩 중...")
                    .font(LDFont.heading04)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                
                // 날짜
                Text(Date.formatShortDate(from: exhibition?.createdAt ?? ""))
                    .font(LDFont.regular03)
                    .foregroundColor(LDColor.color2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                // 반응 목록
                ZStack(alignment: .top) {
                    ScrollView {
                        if viewModel.isLoading {
                            // 로딩 상태
                            ProgressView()
                                .scaleEffect(1.2)
                                .frame(maxWidth: .infinity, minHeight: 400)
                        } else if viewModel.hasReactedArtworks() {
                            // 반응 목록 그리드
                            LazyVGrid(
                                columns: [
                                    GridItem(.fixed(155), spacing: 31),
                                    GridItem(.fixed(155))
                                ],
                                alignment: .leading,
                                spacing: 24
                            ) {
                                ForEach(viewModel.getReactedArtworks(), id: \.id) { artwork in
                                    if let reaction = viewModel.reactions.first(where: {
                                        $0.artworkId == artwork.id
                                    }) {
                                        let artist = viewModel.artist(for: artwork)
                                        ReactionCardView(
                                            reaction: reaction,
                                            artwork: artwork,
                                            artist: artist
                                        )
                                        .onTapGesture {
                                            router.push(.artReaction(artwork: artwork, artist: artist))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 5)
                            .padding(.bottom, 40)
                        } else {
                            // 빈 상태
                            Text("아직 남긴 반응이 없습니다")
                                .font(LDFont.heading06)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, minHeight: 400)
                        }
                    }
                    
                    // 상단 블러 효과
                    LinearGradient(
                        gradient: Gradient(colors: [
                            LDColor.color6,
                            LDColor.color6.opacity(0.8),
                            LDColor.color6.opacity(0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 5)
                    .allowsHitTesting(false)
                }
            }
            .toolbar {
                CustomNavigationBar(title: "") {
                    router.popLast()
                }
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}

struct ReactionCardView: View {
    let reaction: Reaction
    let artwork: Artwork?
    let artist: Artist?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 작품 이미지
            CachedImage(artwork?.thumbnailURL)
                .aspectRatio(contentMode: .fill)
                .frame(width: 157, height: 213)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // 작품 이름
            if let artwork = artwork {
                Text(artwork.title)
                    .font(LDFont.heading04)
                    .foregroundColor(.black)
            }
            // 작가 이름
            if let artist = artist {
                Text(artist.name)
                    .font(LDFont.regular02)
                    .foregroundColor(LDColor.color2)
            }
        }
    }
}

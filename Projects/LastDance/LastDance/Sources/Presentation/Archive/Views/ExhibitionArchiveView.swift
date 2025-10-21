//
//  ExhibitionArchiveView.swift
//  LastDance
//
//  Created by 광로 on 10/14/25.
//

import SwiftData
import SwiftUI

struct ExhibitionArchiveView: View {
    @StateObject private var viewModel: ExhibitionArchiveViewModel
    @EnvironmentObject private var router: NavigationRouter
    @Query private var exhibitions: [Exhibition]

    private var exhibition: Exhibition? {
        exhibitions.first
    }

    init(exhibitionId: Int) {
        _viewModel = StateObject(wrappedValue: ExhibitionArchiveViewModel(
            exhibitionId: exhibitionId
        ))

            // 해당 id에 맞는 Exhibition 정보만 가져옴
        _exhibitions = Query(filter: #Predicate<Exhibition> { exhibition in
            exhibition.id == exhibitionId
        })
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    router.popLast()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(LDColor.color1)
                        .frame(width: 44, height: 44)
                }
                Spacer()
            }
            .padding(.horizontal, 5)
            .padding(.top, 20)
            
            // 전시 제목
            HStack {
                Text(exhibition?.title ?? "전시 정보 로딩 중...")
                    .font(LDFont.heading06)
                    .foregroundColor(LDColor.color1)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            // 날짜
            HStack {
                Text(exhibition?.createdAt ?? "")
                    .font(LDFont.regular03)
                    .foregroundColor(LDColor.color2)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            
            // 반응 목록
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
                            GridItem(.fixed(155), spacing: 16),
                            GridItem(.fixed(155), spacing: 16)
                        ],
                        spacing: 24
                    ) {
                        ForEach(viewModel.getReactedArtworks(), id: \.id) { artwork in
                            if let reaction = viewModel.reactions.first(where: { $0.artworkId == artwork.id }) {
                                ReactionCardView(
                                    reaction: reaction,
                                    artwork: artwork,
                                    artist: viewModel.artist(for: artwork)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                } else {
                    // 빈 상태
                    Text("아직 남긴 반응이 없습니다")
                        .font(LDFont.heading06)
                        .foregroundColor(LDColor.color2)
                        .frame(maxWidth: .infinity, minHeight: 400)
                }
            }
        }
        .background(LDColor.color6)
        .onAppear {
            viewModel.loadData()
            // 방문 기록 생성
            viewModel.createVisitHistory()
            // TODO: 작품 상세뷰 만들어지면 해당 뷰에 연동 예정
            // 임시 테스트: 작품 상세 조회 API 호출
            viewModel.fetchArtworkDetail(artworkId: 1)
        }
        .navigationBarBackButtonHidden()
    }
}

struct ReactionCardView: View {
    let reaction: Reaction
    let artwork: Artwork?
    let artist: Artist?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 작품 이미지
            if let artwork = artwork, let thumbnailURL = artwork.thumbnailURL {
                AsyncImage(url: URL(string: thumbnailURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 155, height: 219)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure(_):
                        Image(thumbnailURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 155, height: 219)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .empty:
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 155, height: 219)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.8)
                            )
                    @unknown default:
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 155, height: 219)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 155, height: 219)
            }
            // 작품 이름
            if let artwork = artwork {
                Text(artwork.title)
                    .font(LDFont.heading04)
                    .foregroundColor(LDColor.color1)
            }
            // 작가 이름
            if let artist = artist {
                Text(artist.name)
                    .font(LDFont.regular02)
                    .foregroundColor(LDColor.color1)
            }
        }
    }
}

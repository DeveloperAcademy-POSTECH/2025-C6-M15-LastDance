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
        _viewModel = StateObject(wrappedValue: ArtistReactionArchiveViewModel(exhibitionId: exhibitionId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    router.popLast()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                Text(viewModel.exhibitionTitle)
                    .font(LDFont.heading04)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ArtistArtworkScrollView(viewModel: viewModel)
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
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(155), spacing: 27),
                        GridItem(.fixed(155), spacing: 27)
                    ],
                    spacing: 28
                ) {
                    ForEach(viewModel.artworks) { displayItem in // Changed from viewModel.reactionItems to viewModel.artworks
                        VStack(alignment: .leading, spacing: 12) {
                            // 작품 카드 이미지
                            ZStack(alignment: .bottomLeading) {
                                if let thumbnailURLString = displayItem.artwork.thumbnailURL,
                                   let thumbnailURL = URL(string: thumbnailURLString) {
                                    AsyncImage(url: thumbnailURL) { phase in
                                        switch phase {
                                        case .empty:
                                            RoundedRectangle(cornerRadius: 0)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 155, height: 219)
                                                .overlay(ProgressView())
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 155, height: 219)
                                                .clipShape(RoundedRectangle(cornerRadius: 0))
                                        case .failure:
                                            RoundedRectangle(cornerRadius: 0)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 155, height: 219)
                                                .overlay(
                                                    Image(systemName: "photo")
                                                        .foregroundColor(.gray)
                                                )
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    RoundedRectangle(cornerRadius: 0)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 155, height: 219)
                                        .overlay(
                                            Text("이미지 없음")
                                                .foregroundColor(.gray)
                                        )
                                }
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
                            // 작품 제목
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

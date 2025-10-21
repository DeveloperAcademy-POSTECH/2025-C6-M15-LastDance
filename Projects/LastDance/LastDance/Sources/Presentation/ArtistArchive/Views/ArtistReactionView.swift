//
//  ArtistReactionArchiveView.swift
//  LastDance
//
//  Created by 광로 on 10/14/25.
//

import SwiftData
import SwiftUI

struct ArtistReactionView: View {
    @StateObject private var viewModel = ArtistReactionViewModel()
    @EnvironmentObject private var router: NavigationRouter
    
    private let gridColumns: [GridItem] = [
        GridItem(.fixed(155), spacing: 31),
        GridItem(.fixed(155), spacing: 31)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("나의 전시")
                .font(LDFont.heading02)
                .foregroundColor(.black)
                .padding(.horizontal, 40)
                .padding(.top, 20)
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ArtistExhibitionGridView(viewModel: viewModel)
            }
        }
        .background(LDColor.color6)
        .overlay(alignment: .bottomTrailing) {
            // 플로팅 버튼
            CircleAddButton {
                router.push(.articleExhibitionList)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            viewModel.loadArtistExhibitions()
        }
    }
}

// MARK: - Extracted Subview for the Grid
private struct ArtistExhibitionGridView: View {
    @ObservedObject var viewModel: ArtistReactionViewModel
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.fixed(155), spacing: 31), // Use the same spacing as gridColumns
                    GridItem(.fixed(155), spacing: 31)
                ],
                spacing: 28
            ) {
                ForEach(viewModel.exhibitions) { displayItem in // Removed .enumerated() as displayItem is Identifiable
                    ArtistExhibitionCard(
                        displayItem: displayItem
                    )
                    .onTapGesture {
                        router.push(.artistReactionArchiveView(exhibitionId: displayItem.exhibition.id))
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 30)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Components (ArtistExhibitionCard remains the same)
struct ArtistExhibitionCard: View {
    let displayItem: ArtistExhibitionDisplayItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 포스터 이미지 + 반응 카운터
            ZStack(alignment: .bottomLeading) {
                if let coverImageURLString = displayItem.exhibition.coverImageName,
                   let coverImageURL = URL(string: coverImageURLString) {
                    AsyncImage(url: coverImageURL) { phase in
                        switch phase {
                        case .empty:
                            // Placeholder while loading
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 155, height: 219)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 155, height: 219)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure:
                            // Placeholder on failure
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 155, height: 219)
                                .overlay(
                                    Image(systemName: "photo") // Changed from "PlaceholderImage"
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 155, height: 219)
                        .overlay(
                            Text("이미지 없음")
                                .foregroundColor(.gray)
                        )
                }
                
                Circle()
                    .fill(Color.black)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text("\(displayItem.reactionCount)")
                            .font(LDFont.heading07)
                            .foregroundColor(.white)
                    )
                    .padding(.leading, 12)
                    .padding(.bottom, 12)
            }
            
            // 전시 제목 (고정 높이로 정렬 보장)
            Text(displayItem.exhibition.title)
                .font(LDFont.medium04)
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 155, height: 44, alignment: .topLeading)
        }
    }
}

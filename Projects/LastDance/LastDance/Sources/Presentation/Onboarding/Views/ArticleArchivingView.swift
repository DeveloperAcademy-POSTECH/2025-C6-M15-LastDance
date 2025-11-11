//
//  ArticleArchivingView.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import SwiftUI

struct ArtistExhibitionCardView: View {
    let displayItem: ArtistExhibitionDisplayItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                if let coverImageURLString = displayItem.exhibition.coverImageName,
                    let coverImageURL = URL(string: coverImageURLString)
                {
                    AsyncImage(url: coverImageURL) { phase in
                        switch phase {
                        case .empty:
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
                            RoundedRectangle(cornerRadius: 12)
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

            Text(displayItem.exhibition.title)
                .font(LDFont.medium04)
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 155, height: 44, alignment: .topLeading)
        }
    }
}

private struct ArtistExhibitionGridView: View {
    @ObservedObject var viewModel: ArtistReactionViewModel
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.fixed(155), spacing: 31),
                    GridItem(.fixed(155), spacing: 31),
                ],
                spacing: 28
            ) {
                ForEach(viewModel.exhibitions) { displayItem in
                    ArtistExhibitionCardView(
                        displayItem: displayItem
                    )
                    .onTapGesture {
                        router.push(
                            .artistReactionArchiveView(exhibitionId: displayItem.exhibition.id))
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 30)
            .padding(.bottom, 100)
        }
    }
}

/// 아카이빙 시작 뷰
struct ArticleArchivingView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ArtistReactionViewModel()

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
            } else if !viewModel.exhibitions.isEmpty {
                ArtistExhibitionGridView(viewModel: viewModel)
            } else {
                Spacer()
                VStack(spacing: 40) {
                    CircleAddButton {
                        router.push(.articleExhibitionList)
                    }

                    Text("나의 작품에 어떤 반응을\n 남겼는지 확인해보세요")
                        .font(LDFont.medium01)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            }
        }
        .background(LDColor.color6)
        .overlay(alignment: .bottomTrailing) {
            if !viewModel.isLoading && !viewModel.exhibitions.isEmpty {
                CircleAddButton {
                    router.push(.articleExhibitionList)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.loadArtistExhibitions()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ArticleArchivingView()
}

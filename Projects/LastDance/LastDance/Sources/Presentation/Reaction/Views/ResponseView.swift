//
//  ResponseView.swift
//  LastDance
//
//  Created by donghee on 10/19/25.
//

import SwiftUI
import SwiftData

struct ResponseView: View {
    @StateObject private var viewModel = ResponseViewModel()
    @Query private var allArtworks: [Artwork]
    let artworkId: Int

    private var artwork: Artwork? {
        viewModel.getArtwork(from: allArtworks, id: artworkId)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ResponseContentView(
                artwork: artwork,
                viewModel: viewModel
            )
            BlurEffectView()
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .ignoresSafeArea(.container, edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(artwork?.title ?? "작품 반응")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        
    }
}
// MARK: - ResponseContentView

struct ResponseContentView: View {
    let artwork: Artwork?

    @ObservedObject var viewModel: ResponseViewModel
    @Environment(\.keyboardManager) var keyboardManager

    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    ArtworkBackgroundView(artwork: artwork)
                        .offset(y: -120)
                        .ignoresSafeArea(.container, edges: .top)
                        .padding(.bottom, -120)

                    ReactionListView(viewModel: viewModel)
                        .padding(.top, 20)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 343 - 120 - 40)
                    ReactionHeaderView(count: viewModel.reactions.count)
                }
            }
            .padding(.bottom, keyboardManager.keyboardHeight)
        }
    }
}

// MARK: - ArtworkBackgroundView

struct ArtworkBackgroundView: View {
    let artwork: Artwork?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 이미지 영역
            if let thumbnailURL = artwork?.thumbnailURL,
               thumbnailURL.hasPrefix("http")
            {
                // 실제 URL인 경우
                AsyncImage(url: URL(string: thumbnailURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 393)
                }
                .frame(maxHeight: 393)
                .clipped()
                
            } else if let imageName = artwork?.thumbnailURL {
                // Mock 데이터
                if UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 393)
                        .clipped()
                } else {
                    // Mock 이미지가 없는 경우
                    Image(systemName: "photo.artframe")
                        .foregroundColor(.gray)
                        .frame(height: 393)
                }
            } else {
                // thumbnailURL이 없는 경우
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 400)
            }

             //그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.97, green: 0.97, blue: 0.97).opacity(0),
                    Color(red: 0.97, green: 0.97, blue: 0.97)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .offset(y: -35)
        .ignoresSafeArea(.container, edges: .top)
    }
}

// MARK: - ReactionListView

struct ReactionListView: View {
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        ReactionItemsView(viewModel: viewModel)
    }
}

// MARK: - ReactionHeaderView

struct ReactionHeaderView: View {
    let count: Int

    var body: some View {
        HStack {
            Text("반응")
                .font(.title3)
                .fontWeight(.bold)
            Text("\(count)")
                .font(Font.custom("Pretendard", size: 14))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black)
                .clipShape(Circle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
        
        
    }
}

// MARK: - ReactionItemsView

struct ReactionItemsView: View {
    @ObservedObject var viewModel: ResponseViewModel
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.reactions.indices, id: \.self) { index in
                ReactionItemView(
                    reaction: viewModel.reactions[index],
                    viewModel: viewModel
                )
                .padding(.horizontal, 20)

                if index < viewModel.reactions.count - 1 {
                    Rectangle()
                        .fill(Color(red: 0.94, green: 0.94, blue: 0.94))
                        .frame(maxWidth: .infinity, maxHeight: 2)
                        .padding(.bottom, 16)
                }
            }
        }
    }
}

// MARK: - BlurEffectView

struct BlurEffectView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.97, green: 0.97, blue: 0.97).opacity(0),
                        Color(red: 0.97, green: 0.97, blue: 0.97)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100 + geometry.safeAreaInsets.bottom)
                .offset(y: geometry.safeAreaInsets.bottom)
                .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - ReactionItemView

struct ReactionItemView: View {
    let reaction: ReactionData
    @ObservedObject var viewModel: ResponseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 댓글 텍스트
            Text(viewModel.displayText(for: reaction))
                .font(.body)
                .lineLimit(viewModel.expandedReactions.contains(reaction.id) ? nil : 3)
                .lineSpacing(10)
                .animation(.easeInOut(duration: 0.3), value: viewModel.expandedReactions.contains(reaction.id))

            // 더보기/접기 버튼
            if reaction.comment.count > 100 {
                Button(action: {
                    viewModel.handleExpandToggle(for: reaction)
                }) {
                    Text(viewModel.expandedReactions.contains(reaction.id) ? "접기" : "더보기")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // 태그들
            CategoryTagsView(
                reaction: reaction,
                viewModel: viewModel
            )
        }
        
        .padding(.vertical, 8)

    }
}

// MARK: - CategoryTagsView

struct CategoryTagsView: View {
    let reaction: ReactionData
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        let firstLine = viewModel.firstLineCategories(for: reaction.categories, reactionId: reaction.id)
        let hidden = viewModel.hiddenCategories(for: reaction.categories, reactionId: reaction.id)
        let showAll = viewModel.showAllReactions[reaction.id] ?? false

        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(firstLine, id: \.self) { category in
                    CategoryTagView(text: category)
                }

                if !showAll && reaction.categories.count >= 2 {
                    MoreCategoriesButton(
                        count: viewModel.hiddenCount(for: reaction),
                        action: { viewModel.toggleShowAllReactions(id: reaction.id) }
                    )
                }

                Spacer()
            }

            if showAll && !hidden.isEmpty {
                HStack(spacing: 8) {
                    ForEach(hidden, id: \.self) { category in
                        CategoryTagView(text: category)
                    }
                    Spacer()
                }
            }
        }
    }
}

// MARK: - CategoryTagView

struct CategoryTagView: View {
    let text: String
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Circle()
                .fill(Color.orange)
                .frame(width: 6, height: 6)

            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.white)
        .cornerRadius(42)
        .shadow(color: .black.opacity(0.24), radius: 0.5, x: 0, y: 0)
    }
}

// MARK: - MoreCategoriesButton

struct MoreCategoriesButton: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("+\(count)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white)
                .cornerRadius(42)
                .shadow(color: .black.opacity(0.24), radius: 0.5, x: 0, y: 0)
        }
    }
}

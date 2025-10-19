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
        allArtworks.first { $0.id == artworkId }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ResponseContentView(
                artworkId: artworkId,
                viewModel: viewModel
            )
            BlurEffectView()
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarTitle("작품 반응", displayMode: .inline)
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
    let artworkId: Int

    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ArtworkBackgroundView(artworkId: artworkId)
                    ReactionListView(viewModel: viewModel)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - ArtworkBackgroundView

struct ArtworkBackgroundView: View {
    @Query private var allArtworks: [Artwork]
    let artworkId: Int
    
    private var artwork: Artwork? {
        allArtworks.first { $0.id == artworkId }
    }

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
                        .frame(height: 343)
                }
                .frame(maxHeight: 343)
                .clipped()
            } else if let imageName = artwork?.thumbnailURL {
                // Mock 데이터
                if UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 373)
                        .clipped()
                } else {
                    // Mock 이미지가 없는 경우
                    Image(systemName: "photo.artframe")
                        .foregroundColor(.gray)
                        .frame(height: 343)
                }
            } else {
                // thumbnailURL이 없는 경우
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 343)
            }

            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.97, green: 0.97, blue: 0.97).opacity(0),
                    Color(red: 0.97, green: 0.97, blue: 0.97)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .offset(y: -120)
        .ignoresSafeArea(.container, edges: .top)
        .padding(.bottom, -120)
    }
}

// MARK: - ReactionListView

struct ReactionListView: View {
    @ObservedObject var viewModel: ResponseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 50) {
            ReactionHeaderView(count: viewModel.sampleReactions.count)

            ReactionItemsView(viewModel: viewModel)
        }
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
        .padding(.horizontal, 24)
    }
}

// MARK: - ReactionItemsView

struct ReactionItemsView: View {
    @ObservedObject var viewModel: ResponseViewModel
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.sampleReactions.indices, id: \.self) { index in
                ReactionItemView(
                    reaction: viewModel.sampleReactions[index],
                    viewModel: viewModel
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                if index < viewModel.sampleReactions.count - 1 {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 393.00003, height: 1.8)
                        .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                        .padding(.horizontal, 28)
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
                categories: reaction.categories,
                showAllReactions: viewModel.showAllReactions[reaction.id] ?? false,
                hiddenCount: viewModel.hiddenCount(for: reaction),
                didTapShowAllToggle: {
                    viewModel.toggleShowAllReactions(id: reaction.id)
                }
            )
        }
        .padding(.vertical, 16)
    }
}

// MARK: - CategoryTagsView

struct CategoryTagsView: View {
    let categories: [String]
    let showAllReactions: Bool
    let hiddenCount: Int
    let didTapShowAllToggle: () -> Void
    
    private var firstLineCategories: [String] {
        if showAllReactions {
            return Array(categories.prefix(2))
        } else {
            return Array(categories.prefix(1))
        }
    }
    
    private var hiddenCategories: [String] {
        if showAllReactions && categories.count > 2 {
            return Array(categories.dropFirst(2))
        } else {
            return []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(firstLineCategories, id: \.self) { category in
                    CategoryTagView(text: category)
                }
                
                if !showAllReactions && categories.count >= 2 {
                    CategoryTagView(text: "+\(hiddenCount)", isButton: true, action: didTapShowAllToggle)
                }
                
                Spacer()
            }
            
            if showAllReactions && !hiddenCategories.isEmpty {
                HStack(spacing: 8) {
                    ForEach(hiddenCategories, id: \.self) { category in
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
    let isButton: Bool
    let action: (() -> Void)?
    
    init(text: String, isButton: Bool = false, action: (() -> Void)? = nil) {
        self.text = text
        self.isButton = isButton
        self.action = action
    }
    
    var body: some View {
        Group {
            if isButton, let action = action {
                Button(action: action) {
                    tagContent
                }
            } else {
                tagContent
            }
        }
    }
    
    private var tagContent: some View {
        HStack(alignment: .center, spacing: 8) {
            if !isButton {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 6, height: 6)
            }
            
            Text(text)
                .font(.caption)
                .foregroundColor(isButton ? .gray : .primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.white)
        .cornerRadius(42)
        .shadow(color: .black.opacity(0.24), radius: 0.5, x: 0, y: 0)
    }
}

#Preview {
    NavigationView {
        ResponseView(artworkId: 1)
    }
}

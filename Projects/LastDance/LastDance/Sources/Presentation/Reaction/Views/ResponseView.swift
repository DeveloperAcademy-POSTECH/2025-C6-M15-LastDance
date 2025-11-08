//
//  ResponseView.swift
//  LastDance
//
//  Created by donghee on 10/19/25.
//

import SwiftData
import SwiftUI

struct ResponseView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel: ResponseViewModel
    @Query private var allArtworks: [Artwork]
    let artworkId: Int

    init(artworkId: Int) {
        self.artworkId = artworkId
        _viewModel = StateObject(wrappedValue: ResponseViewModel(artworkId: artworkId))
    }

    private var artwork: Artwork? {
        allArtworks.first { $0.id == artworkId }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ResponseContentView(
                    artwork: artwork,
                    viewModel: viewModel
                )
            }
            BlurEffectView()
        }
        .background(LDColor.color5)
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomWhiteNavigationBar(title: artwork?.title ?? "작품 반응" ) {
                router.popLast()
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

// MARK: - ResponseContentView

struct ResponseContentView: View {
    let artwork: Artwork?

    @ObservedObject var viewModel: ResponseViewModel

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
        }
        .scrollToMinDistance(minDisntance: 32)
    }
}

// MARK: - ArtworkBackgroundView

struct ArtworkBackgroundView: View {
    let artwork: Artwork?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 이미지 영역
            if let thumbnailURL = artwork?.thumbnailURL,
               thumbnailURL.hasPrefix("http") {
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
                    LDColor.color5.opacity(0),
                    LDColor.color5
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
                .font(LDFont.heading03)
            Text("\(count)")
                .font(LDFont.regular03)
                .foregroundColor(LDColor.color6)
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
                        .foregroundColor(.clear)
                        .frame(height: 2)
                        .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                        .padding(.bottom, 16)
                }
            }
        }
        .padding(.bottom, 120)
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
                        LDColor.color5.opacity(0),
                        LDColor.color5
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
                .font(LDFont.medium03)
                .lineLimit(viewModel.expandedReactions.contains(reaction.id) ? nil : 3)
                .lineSpacing(10)
                .animation(.easeInOut(duration: 0.3), value: viewModel.expandedReactions.contains(reaction.id))

            // 더보기/접기 버튼
            if reaction.comment.count > 100 {
                Button(action: {
                    viewModel.handleExpandToggle(for: reaction)
                }) {
                    Text(viewModel.expandedReactions.contains(reaction.id) ? "접기" : "더보기")
                        .font(LDFont.medium05)
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
        let showAll = viewModel.showAllReactions[reaction.id] ?? false
        let displayCategories = showAll ? reaction.categories : Array(reaction.categories.prefix(1))

        FlowLayout(spacing: 8) {
            ForEach(displayCategories, id: \.self) { category in
                CategoryTagView(text: category)
                    .onTapGesture {
                        if showAll {
                            viewModel.toggleShowAllReactions(id: reaction.id)
                        }
                    }
            }

            if !showAll && reaction.categories.count >= 2 {
                MoreCategoriesButton(
                    count: viewModel.hiddenCount(for: reaction),
                    action: { viewModel.toggleShowAllReactions(id: reaction.id) }
                )
            }
        }
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    // 다음 줄로 이동
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
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
                .font(LDFont.medium06)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(LDColor.color6)
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
                .font(LDFont.medium06)
                .foregroundColor(.gray)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(LDColor.color6)
                .cornerRadius(42)
                .shadow(color: .black.opacity(0.24), radius: 0.5, x: 0, y: 0)
        }
    }
}

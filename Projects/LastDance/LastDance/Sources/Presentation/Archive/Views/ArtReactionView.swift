//
//  ArtReactionView.swift
//  LastDance
//
//  Created by 광로 on 10/20/25.
//

import SwiftUI

struct ArtReactionView: View {
    let artwork: Artwork
    let artist: Artist?

    @StateObject private var viewModel: ArtReactionViewModel
    @EnvironmentObject private var router: NavigationRouter
    @State private var selectedTab: ArtReactionTab = .artwork
    @State private var scrollOffset: CGFloat = 0
    @State private var didSnap: Bool = false

    init(artwork: Artwork, artist: Artist?) {
        self.artwork = artwork
        self.artist = artist
        _viewModel = StateObject(
            wrappedValue: ArtReactionViewModel(artworkId: artwork.id)
        )
    }

    // MARK: - Computed Properties

    private var isTabBarFixed: Bool {
        scrollOffset > ArchiveImageConstants.tabBarFixThreshold
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 스크롤 가능한 콘텐츠
            scrollContent

            // 최상단 고정 탭바
            TabBarView(selectedTab: $selectedTab)
                .background(Color.white)
                .opacity(isTabBarFixed ? 1 : 0)
        }
        .background(Color.white)
        .toolbar {
            CustomNavigationBar(title: "") {
                router.popLast()
            }
        }
        .onAppear {
            viewModel.loadReactions()
        }
    }
}

// MARK: - Scroll Content
extension ArtReactionView {
    fileprivate var scrollContent: some View {
        SnappingScrollView(
            content: {
                VStack(spacing: 0) {
                    // 작품 이미지
                    headerImage
                        .padding(.vertical, 24)

                    // 스크롤 안에 들어오는 탭바
                    TabBarView(selectedTab: $selectedTab)
                        .opacity(isTabBarFixed ? 0 : 1)

                    ZStack {
                        // 작품 정보 탭
                        artworkTabSection
                            .opacity(selectedTab == .artwork ? 1 : 0)

                        // 감상 탭
                        reactionTabSection
                            .opacity(selectedTab == .reaction ? 1 : 0)
                    }
                }
            },
            onScroll: { offset, scrollView in
                scrollOffset = offset

                let snapThreshold = ArchiveImageConstants.tabBarFixThreshold + 190
                let resetThreshold = snapThreshold - 40

                if !didSnap && offset >= snapThreshold {
                    didSnap = true

                    scrollView.setContentOffset(.init(x: 0, y: snapThreshold), animated: false)

                    scrollView.isScrollEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        scrollView.isScrollEnabled = true
                    }
                } else if didSnap && offset < resetThreshold {
                    didSnap = false
                }
            },
            onRefresh: {
                viewModel.loadReactions()
            }
        )
    }

    fileprivate var headerImage: some View {
        // 스크롤에 따라 이미지 크기 조정 (최대값 제한 추가)
        let imageHeight = min(
            ArchiveImageConstants.maxHeight,
            max(
                ArchiveImageConstants.minHeight,
                ArchiveImageConstants.maxHeight - scrollOffset * 0.5
            )
        )
        let imageWidth = min(
            ArchiveImageConstants.maxWidth,
            max(
                ArchiveImageConstants.minWidth,
                ArchiveImageConstants.maxWidth - (ArchiveImageConstants.maxHeight - imageHeight)
                    * 0.76
            )
        )

        return Group {
            if let imageURLString = artwork.thumbnailURL {
                CachedImage(
                    imageURLString,
                    targetSize: .init(
                        width: ArchiveImageConstants.maxWidth,
                        height: ArchiveImageConstants.maxHeight
                    )
                )
                .aspectRatio(contentMode: .fill)
                .frame(width: imageWidth, height: imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(LDColor.color5, lineWidth: 10)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 0)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: imageWidth, height: imageHeight)
                    .cornerRadius(24)
                    .overlay(Text("이미지 없음").foregroundColor(.gray))
            }
        }
    }
}

// MARK: - 작품 탭 뷰
extension ArtReactionView {
    fileprivate var artworkTabSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(artwork.title)
                .font(LDFont.heading03)
                .foregroundColor(LDColor.color1)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text(viewModel.artistName)
                    .font(LDFont.medium04)
                    .foregroundColor(LDColor.color6)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(LDColor.color1)
                    .cornerRadius(20)
                Spacer()
            }

            Rectangle()
                .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [4]))
                .frame(height: 0.5)
                .foregroundColor(LDColor.color3)

            Text("작품 설명")
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.description)
                .font(LDFont.medium04)
                .foregroundColor(LDColor.color2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(4)

            Spacer(minLength: ArchiveImageConstants.animationThreshold)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 44)
    }
}

// MARK: - 감상 탭
extension ArtReactionView {
    fileprivate var reactionTabSection: some View {
        VStack(alignment: .leading, spacing: 36) {
            // 작가가 남긴 메시지
            artistMessageSection

            // 나의 감상
            myReactionSection

            Spacer(minLength: ArchiveImageConstants.animationThreshold)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 40)
    }

    // 작가 메시지 영역
    private var artistMessageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("작가가 남긴 메시지")
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)

            HStack {
                // 모든 반응에서 이모지가 있는 것만 필터링 후 최신순 정렬
                let latestEmoji = viewModel.reactions
                    .filter { $0.artistEmoji != nil }
                    .sorted { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
                    .first?.artistEmoji

                if let emoji = latestEmoji {
                    HStack(spacing: 4) {
                        Image(emoji)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)

                        Text(ReactionConstants.emojiText(for: emoji))
                            .font(LDFont.regular03)
                            .foregroundColor(LDColor.color1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LDColor.color4)
                    )
                } else {
                    Text("아직 이모지가 없습니다.")
                        .font(LDFont.regular03)
                        .foregroundColor(LDColor.color2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(LDColor.color4)
                        )
                }

                Spacer()
            }

            HStack(alignment: .top, spacing: 12) {
                Image("quote_left")
                    .renderingMode(.template)
                    .foregroundColor(LDColor.color1)
                    .frame(width: 24, height: 24)
                    .offset(y: -4)

                VStack(alignment: .leading, spacing: 8) {
                    // 모든 반응에서 메시지 수집 후 최신순 정렬
                    let allMessages = viewModel.reactions
                        .flatMap { $0.artistMessages ?? [] }
                        .sorted { $0.createdAt > $1.createdAt }

                    // 최신 메시지 1개만 표시
                    if let latestMessage = allMessages.first {
                        Text(latestMessage.message)
                            .font(LDFont.regular02)
                            .foregroundColor(LDColor.color1)
                            .lineSpacing(4)
                    } else {
                        Text("아직 메시지가 없습니다.")
                            .font(LDFont.regular02)
                            .foregroundColor(LDColor.color3)
                    }
                }

                Image("quote_right")
                    .renderingMode(.template)
                    .foregroundColor(LDColor.color1)
                    .frame(width: 24, height: 24)
                    .offset(y: -4)
            }
            .padding(12)
        }
    }
    // 나의 감상 영역
    private var myReactionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("나의 감상")
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.0)
                    .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
                    .padding(.top, 8)

            } else if viewModel.reactions.isEmpty {
                Text("아직 등록된 감상이 없습니다")
                    .font(LDFont.medium04)
                    .foregroundColor(LDColor.color2)
                    .padding(.top, 4)

            } else {
                ForEach(viewModel.reactions, id: \.id) { reaction in
                    if let comment = reaction.comment, !comment.isEmpty {
                        Text(comment)
                            .padding(12)
                            .font(LDFont.medium04)
                            .foregroundColor(LDColor.color1)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LDColor.color5)
                            )
                    }
                }
            }
        }
    }
}

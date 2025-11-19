//
//  ResponseView.swift
//  LastDance
//
//  Created by donghee on 10/19/25.
//

import SwiftData
import SwiftUI

fileprivate enum ResponseTab {
    case artwork
    case message
}

struct ResponseView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel: ResponseViewModel
    @Query private var allArtworks: [Artwork]
    @State fileprivate var selectedTab: ResponseTab = .artwork
    let artworkId: Int

    init(artworkId: Int) {
        self.artworkId = artworkId
        _viewModel = StateObject(wrappedValue: ResponseViewModel(artworkId: artworkId))
    }

    private var artwork: Artwork? {
        allArtworks.first { $0.id == artworkId }
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ResponseContentView(
                    artwork: artwork,
                    viewModel: viewModel,
                    selectedTab: $selectedTab
                )
            }
        }
        .background(LDColor.color5)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomWhiteNavigationBar(title: artwork?.title ?? "작품 반응") {
                router.popLast()
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - ResponseContentView

struct ResponseContentView: View {
    let artwork: Artwork?
    @ObservedObject var viewModel: ResponseViewModel
    @Binding fileprivate var selectedTab: ResponseTab

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                ArtworkBackgroundView(artwork: artwork)
                    .frame(height: 393)
                    .clipped()

                // 탭 바를 이미지 위에 배치
                ResponseTabBar(selectedTab: $selectedTab)
                    .padding(.bottom, 24)
            }
            .ignoresSafeArea(edges: .top)

            // 콘텐츠만 스크롤 (상단 블러 포함)
            ZStack(alignment: .top) {
                ScrollView {
                    if selectedTab == .artwork {
                        ArtworkInfoSection(artwork: artwork, viewModel: viewModel)
                    } else {
                        MessageListView(viewModel: viewModel)
                    }
                }
                .background(LDColor.color5)

                // 스크롤뷰 상단 블러 효과
                LinearGradient(
                    gradient: Gradient(colors: [
                        LDColor.color5,
                        LDColor.color5.opacity(0.8),
                        LDColor.color5.opacity(0.3),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 40)
                .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - ResponseTabBar

struct ResponseTabBar: View {
    @Binding fileprivate var selectedTab: ResponseTab

    var body: some View {
        HStack(spacing: 18) {
            Button(action: {
                selectedTab = .artwork
            }) {
                Text("작품")
                    .font(LDFont.heading03)
                    .foregroundColor(selectedTab == .artwork ? LDColor.color1 : LDColor.color2)
            }

            Button(action: {
                selectedTab = .message
            }) {
                Text("메시지")
                    .font(LDFont.heading03)
                    .foregroundColor(selectedTab == .message ? LDColor.color1 : LDColor.color2)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - ArtworkInfoSection

struct ArtworkInfoSection: View {
    let artwork: Artwork?
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 반응 수
            Text("반응 수")
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)
                .padding(.top, 36)

            Text("\(viewModel.reactions.count)")
                .font(LDFont.heading01)
                .foregroundColor(LDColor.color1)
                .padding(.top, 8)

            // 작품 제목
            Text("작품 제목")
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)
                .padding(.top, 48)

            Text(artwork?.title ?? "")
                .font(LDFont.heading03)
                .foregroundColor(LDColor.color1)
                .padding(.top, 8)

            // 작품 설명
            Text("작품 설명")
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)
                .padding(.top, 36)

            if let description = artwork?.descriptionText, !description.isEmpty {
                Text(description)
                    .font(LDFont.medium03)
                    .foregroundColor(LDColor.color2)
                    .lineSpacing(4)
                    .padding(.top, 8)
            } else {
                Text("작품 설명이 없습니다.")
                    .font(LDFont.medium03)
                    .foregroundColor(LDColor.color2)
                    .padding(.top, 8)
            }

            Spacer(minLength: 100)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

// MARK: - MessageListView

struct MessageListView: View {
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<viewModel.reactions.count, id: \.self) { index in
                MessageItemView(
                    reaction: viewModel.reactions[index],
                    index: index,
                    viewModel: viewModel,
                    isLast: index == viewModel.reactions.count - 1
                )
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 100)
    }
}

// MARK: - MessageItemView

struct MessageItemView: View {
    let reaction: ReactionData
    let index: Int
    @ObservedObject var viewModel: ResponseViewModel
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // 헤더 (프로필 + 이름 + 날짜)
                HStack(spacing: 0) {
                    // TODO: 실제 프로필 이미지로 교체
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(viewModel.getMockEmoji(for: index))
                                .font(.system(size: 20))
                        )

                    // TODO: 실제 사용자 이름으로 교체
                    Text(viewModel.getMockName(for: index))
                        .font(LDFont.medium04)
                        .foregroundColor(LDColor.color1)
                        .padding(.leading, 12)

                    Spacer()

                    // TODO: reaction 데이터에 날짜 필드 추가하여 실제 날짜로 교체
                    Text(viewModel.getMockDate())
                        .font(LDFont.medium05)
                        .foregroundColor(LDColor.color3)
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.bottom, 8)

                // 댓글 텍스트
                if !reaction.comment.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.displayText(for: reaction))
                            .font(LDFont.medium03)
                            .foregroundColor(LDColor.color1)
                            .lineLimit(viewModel.expandedReactions.contains(reaction.id) ? nil : 3)
                            .lineSpacing(6)

                        if reaction.comment.count > 80 {
                            Button(action: {
                                viewModel.handleExpandToggle(for: reaction)
                            }) {
                                Text(viewModel.expandedReactions.contains(reaction.id) ? "접기" : "더보기")
                                    .font(LDFont.medium05)
                                    .foregroundColor(LDColor.color3)
                            }
                        }
                    }
                    .padding(.leading, 72)
                    .padding(.trailing, 20)
                    .padding(.bottom, 12)
                }

                // 하트 + 공유 버튼
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .font(.system(size: 24))
                            .foregroundColor(LDColor.color2)
                    }

                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 24))
                            .foregroundColor(LDColor.color2)
                    }

                    Spacer()
                }
                .padding(.leading, 72)
                .padding(.trailing, 20)
            }
            .padding(.top, 20)
            .padding(.bottom, 20)

            if !isLast {
                Rectangle()
                    .fill(LDColor.gray8)
                    .frame(height: 1)
            }
        }
    }
}


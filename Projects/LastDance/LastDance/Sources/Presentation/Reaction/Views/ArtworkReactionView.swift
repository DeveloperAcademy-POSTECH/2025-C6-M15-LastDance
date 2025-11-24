//
//  ArtworkReactionView.swift
//  LastDance
//
//  Created by donghee, 신얀 on 10/19/25.
//

import SwiftData
import SwiftUI

// MARK: ArtworkReactionView

struct ArtworkReactionView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel: ArtworkReactionViewModel
    @Query private var allArtworks: [Artwork]
    @State fileprivate var selectedTab: ArtworkReactionTab = .artwork
    let artworkId: Int

    init(artworkId: Int) {
        self.artworkId = artworkId
        _viewModel = StateObject(wrappedValue: ArtworkReactionViewModel(artworkId: artworkId))
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
        .overlay(alignment: .top) {
            NavigationBarGradientView()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomWhiteNavigationBar(title: LocalizedStringKey(artwork?.title ?? "작품 반응")) {
                router.popLast()
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            viewModel.fetchReactions()
        }
    }

    struct NavigationBarGradientView: View {
        var body: some View {
            LinearGradient(
                colors: [
                    Color.black.opacity(1.0),
                    Color.black.opacity(0.4),
                    Color.clear,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)
        }
    }
}

// MARK: - ResponseContentView

struct ResponseContentView: View {
    let artwork: Artwork?
    @ObservedObject var viewModel: ArtworkReactionViewModel
    @Binding fileprivate var selectedTab: ArtworkReactionTab

    @State private var emojiPopupPosition: CGRect = .zero
    @State private var showEmojiPopup: Bool = false
    @State private var showMessagePopup: Bool = false
    @State private var selectedReactionForMessage: ReactionData?

    var body: some View {
        ZStack(alignment: .top) {
            // 배경 이미지
            ArtworkBackgroundView(artwork: artwork)
                .frame(height: 393)
                .clipped()
                .overlay(alignment: .bottomLeading) {
                    // 탭 바를 이미지 위에 배치
                    ResponseTabBar(selectedTab: $selectedTab)
                        .padding(.bottom, 24)
                }
                .ignoresSafeArea(edges: .top)

            // 콘텐츠만 스크롤 (상단 블러 포함)
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 393)

                ZStack(alignment: .top) {
                    ScrollView {
                        if selectedTab == .artwork {
                            ArtworkInfoSection(artwork: artwork, viewModel: viewModel)
                        } else {
                            MessageListView(
                                viewModel: viewModel,
                                showEmojiPopup: $showEmojiPopup,
                                emojiPopupPosition: $emojiPopupPosition,
                                showMessagePopup: $showMessagePopup,
                                selectedReactionForMessage: $selectedReactionForMessage
                            )
                        }
                    }
                    .disabled(showEmojiPopup)
                    .background(LDColor.color5)

                    // 스크롤뷰 상단 블러 효과
                    LinearGradient(
                        gradient: Gradient(colors: [
                            LDColor.color5,
                            LDColor.color5.opacity(0.8),
                            LDColor.color5.opacity(0.3),
                            Color.clear,
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 20)
                    .allowsHitTesting(false)
                }
            }

            // 이모지 팝업을 최상위 레이어에 배치
            if showEmojiPopup {
                EMojiPopupView { selectedEmoji in
                    viewModel.sendEmoji(selectedEmoji)
                    withAnimation(.easeOut) {
                        showEmojiPopup = false
                    }
                }
                .position(
                    x: emojiPopupPosition.midX + 120,
                    y: emojiPopupPosition.maxY + 40
                )
                .transition(AnyTransition.scale.combined(with: .opacity))
                .zIndex(10)
            }

            // 메시지 팝업을 최상위 레이어에 배치
            if showMessagePopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showMessagePopup = false
                        }
                    }
                    .zIndex(20)

                GeometryReader { geometry in
                    MessagePopupView(
                        showMessagePopup: $showMessagePopup,
                        viewModel: viewModel,
                        reaction: selectedReactionForMessage
                    )
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
                    .transition(.opacity.combined(with: .scale))
                }
                .zIndex(21)
            }
        }
    }
}

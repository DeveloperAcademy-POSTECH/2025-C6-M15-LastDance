//
//  ArtworkReactionView.swift
//  LastDance
//
//  Created by donghee, 신얀 on 10/19/25.
//

import SwiftData
import SwiftUI

// MARK: ArtworkReactionTab

private enum ArtworkReactionTab {
    case artwork
    case message
}

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
    @ObservedObject var viewModel: ArtworkReactionViewModel
    @Binding fileprivate var selectedTab: ArtworkReactionTab

    @State private var emojiPopupPosition: CGRect = .zero
    @State private var showEmojiPopup: Bool = false
    @State private var showMessagePopup: Bool = false

    var body: some View {
        ZStack {
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
                            MessageListView(
                                viewModel: viewModel,
                                showEmojiPopup: $showEmojiPopup,
                                emojiPopupPosition: $emojiPopupPosition,
                                showMessagePopup: $showMessagePopup
                            )
                        }
                    }
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
                    .frame(height: 40)
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

                MessagePopupView(showMessagePopup: $showMessagePopup)
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(21)
            }
        }
    }
}

// MARK: - ResponseTabBar

struct ResponseTabBar: View {
    @Binding fileprivate var selectedTab: ArtworkReactionTab

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
    @ObservedObject var viewModel: ArtworkReactionViewModel

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
    @ObservedObject var viewModel: ArtworkReactionViewModel
    @Binding var showEmojiPopup: Bool
    @Binding var emojiPopupPosition: CGRect
    @Binding var showMessagePopup: Bool

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<viewModel.reactions.count, id: \.self) { index in
                MessageItemView(
                    reaction: viewModel.reactions[index],
                    index: index,
                    viewModel: viewModel,
                    isLast: index == viewModel.reactions.count - 1,
                    showEmojiPopup: $showEmojiPopup,
                    emojiPopupPosition: $emojiPopupPosition,
                    showMessagePopup: $showMessagePopup
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
    @ObservedObject var viewModel: ArtworkReactionViewModel
    let isLast: Bool
    @Binding var showEmojiPopup: Bool
    @Binding var emojiPopupPosition: CGRect
    @Binding var showMessagePopup: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(Date.formatShortDate(from: reaction.createdAt))
                    .font(LDFont.medium05)
                    .foregroundColor(LDColor.color3)

                Spacer().frame(height: 8)

                // 댓글 텍스트
                if !reaction.comment.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.displayText(for: reaction))
                            .font(LDFont.medium03)
                            .foregroundColor(LDColor.color1)
                            .lineLimit(viewModel.expandedReactions.contains(reaction.id) ? nil : 3)
                            .lineSpacing(6)

                        // TODO: 글자수 말고 글자 높이, 너비로 접기-더보기 수정
                        if reaction.comment.count > 80 {
                            Button(action: {
                                viewModel.handleExpandToggle(for: reaction)
                            }) {
                                Text(
                                    viewModel.expandedReactions.contains(reaction.id) ? "접기" : "더보기"
                                )
                                .font(LDFont.medium05)
                                .foregroundColor(LDColor.color3)
                            }
                        }
                    }
                    .padding(.bottom, 12)
                }

                HStack(spacing: 18) {
                    GeometryReader { proxy in
                        Button(action: {
                            // 이미지 리스트에서 클릭된 이모지가 없다면 -> defaultImage
                            if viewModel.getSelectedEmoji(for: reaction.id) == nil {
                                viewModel.selectedReactionId = reaction.id
                                emojiPopupPosition = proxy.frame(in: .global)
                                showEmojiPopup = true
                            }
                        }) {
                            // 선택된 이미지가 존재한다면 그걸로 표시
                            if let selectedEmoji = viewModel.getSelectedEmoji(for: reaction.id) {
                                Image(selectedEmoji)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 29, height: 27)
                            } else {
                                Image(
                                    viewModel.selectedReactionId == reaction.id
                                        ? "defaultImageFill" : "defaultImage"
                                )
                                .resizable()
                                .scaledToFill()
                                .frame(width: 26, height: 27)
                            }
                        }
                        .disabled(viewModel.getSelectedEmoji(for: reaction.id) != nil)
                    }
                    .frame(width: 26, height: 27)

                    Button(action: {
                        showMessagePopup = true
                    }) {
                        Image("bubbleOff")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 26, height: 25)
                    }
                    Spacer()
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 20)
            .padding(.horizontal, 24)

            if !isLast {
                Rectangle()
                    .fill(LDColor.gray8)
                    .frame(height: 1)
            }
        }
    }
}

// MARK: 작가 반응 확인뷰에서만 사용되는 이모지 팝업
private struct EMojiPopupView: View {
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(ReactionConstants.emojiAssets, id: \.self) { assetName in
                Button(action: {
                    onSelect(assetName)
                }) {
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .padding(1)
                }
            }
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.white)
        .cornerRadius(40)
        .shadow(color: .black.opacity(0.25), radius: 6, x: 1, y: 3)
    }
}

// MARK: 작가 반응 확인뷰에서만 사용되는 반응 전송 팝업
private struct MessagePopupView: View {
    @Binding var showMessagePopup: Bool
    @State private var messageText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image("bubbleOff")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 27, height: 25)

            Text("메시지에 반응해보세요")
                .font(LDFont.heading04)
                .foregroundStyle(LDColor.color1)
                .lineSpacing(5)

            TextField("10자 이내로 입력해주세요", text: $messageText)
                .font(LDFont.medium03)
                .foregroundStyle(LDColor.color1)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LDColor.color4, lineWidth: 1)
                )
                .focused($isTextFieldFocused)
                .padding(.horizontal, 12)

            Spacer().frame(height: 10)

            HStack(spacing: 9) {
                Button(
                    action: {
                        showMessagePopup = false
                    },
                    label: {
                        Text("취소")
                            .font(LDFont.heading06)
                            .foregroundStyle(LDColor.black1)
                            .frame(maxWidth: .infinity, minHeight: 42)
                            .background(LDColor.color4)
                            .cornerRadius(12)
                    })

                Button(
                    action: {
                        // TODO: 메시지 전송 로직
                        showMessagePopup = false
                    },
                    label: {
                        Text("확인")
                            .font(LDFont.heading06)
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, minHeight: 42)
                            .background(LDColor.black1)
                            .cornerRadius(12)
                    })
            }
            .padding(.horizontal, 12)
        }
        .frame(width: 293)
        .padding(.top, 28)
        .padding(.bottom, 27)
        .background(LDColor.color5)
        .cornerRadius(14)
    }
}

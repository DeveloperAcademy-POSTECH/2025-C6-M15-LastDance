//
//  ArtReactionSendView.swift
//  LastDance
//
//  Created by 배현진 on 11/21/25.
//

import SwiftUI
import UIKit

struct ArtReactionSendView: View {
    let artwork: Artwork
    let artist: Artist
    let exhibitionId: Int
    let imageData: Data

    @StateObject private var viewModel: ArtReactionViewModel
    @EnvironmentObject private var router: NavigationRouter
    @State private var selectedTab: ArtReactionTab = .artwork
    @State private var scrollOffset: CGFloat = 0
    @State private var didSnap: Bool = false
    @FocusState private var isMessageFieldFocused: Bool
    @State private var saveNoticeVisible = false

    private let placeholder = ReactionConstants.messagePlaceholder

    init(artwork: Artwork, artist: Artist, exhibitionId: Int, imageData: Data) {
        self.artwork = artwork
        self.artist = artist
        self.exhibitionId = exhibitionId
        self.imageData = imageData
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

            // 하단 버튼
            VStack {
                Spacer()

                if selectedTab == .reaction {
                    BottomButton(
                        text: "전송하기",
                        isEnabled: !viewModel.isSendButtonDisabled,
                        action: {
                            viewModel.sendButtonAction()
                        }
                    )
                    .background(LDColor.color6)
                }
            }

            // 저장 완료 알림
            if saveNoticeVisible {
                VStack {
                    HStack(spacing: 8) {
                        Image("CheckIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)

                        Text("이미지가 갤러리에 저장되었습니다.")
                            .font(LDFont.medium04)
                            .foregroundStyle(LDColor.color1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .cornerRadius(12)
                    .shadow(LDShadow.shadow4)
                    .shadow(LDShadow.shadow5)
                    .shadow(LDShadow.shadow6)
                    .offset(y: 35)

                    Spacer()
                }
            }
        }
        .background(Color.white)
        .toolbar {
            CustomNavigationBar(title: "") {
                router.popLast()
            }
        }
        .onAppear {
            viewModel.capturedImageData = imageData

            withAnimation(.easeInOut(duration: 0.3)) {
                saveNoticeVisible = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    saveNoticeVisible = false
                }
            }
        }
        .onChange(of: viewModel.shouldTriggerSend) { _, shouldTrigger in
            if shouldTrigger {
                viewModel.performSendReaction(artworkId: artwork.id, exhibitionId: exhibitionId) {
                    success, exhibitionId in
                    if success, let exhibitionId = exhibitionId {
                        router.push(.completeReaction(exhibitionId: exhibitionId))
                    }
                }
                viewModel.shouldTriggerSend = false
            }
        }
        .customAlert(
            isPresented: $viewModel.shouldShowConfirmAlert,
            image: viewModel.alertType.image,
            title: viewModel.alertType.title,
            message: viewModel.alertType.message,
            buttonText: viewModel.alertType.buttonText,
            action: {
                if viewModel.alertType == .confirmation {
                    viewModel.confirmSendAction()
                } else {
                    viewModel.handleRestrictionAlertDismiss()
                    viewModel.shouldShowConfirmAlert = false
                }
            },
            cancelAction: {
                viewModel.shouldShowConfirmAlert = false
            }
        )
    }
}

// MARK: - Scroll Content
extension ArtReactionSendView {
    fileprivate var scrollContent: some View {
        SnappingScrollView {
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
        } onScroll: { offset, scrollView in
            scrollOffset = offset

            let snapThreshold = ArchiveImageConstants.tabBarFixThreshold + 200
            let resetThreshold = snapThreshold - 40

            if !didSnap && offset >= snapThreshold {
                didSnap = true

                scrollView.setContentOffset(.init(x: 0, y: snapThreshold), animated: true)

                scrollView.isScrollEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    scrollView.isScrollEnabled = true
                }
            } else if didSnap && offset < resetThreshold {
                didSnap = false
            }
        }
    }

    fileprivate var headerImage: some View {
        // 스크롤에 따라 이미지 크기 조정
        let imageHeight = max(
            ArchiveImageConstants.minHeight,
            ArchiveImageConstants.maxHeight - scrollOffset * 1.0
        )
        let imageWidth = max(
            ArchiveImageConstants.minWidth,
            ArchiveImageConstants.maxWidth - (ArchiveImageConstants.maxHeight - imageHeight) * 0.76
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
extension ArtReactionSendView {
    fileprivate var artworkTabSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(artwork.title)
                .font(LDFont.heading03)
                .foregroundColor(LDColor.color1)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text(artist.name)
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

            if let description = artwork.descriptionText, !description.isEmpty {
                Text("작품 설명")
                    .font(LDFont.heading04)
                    .foregroundColor(LDColor.color1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(description)
                    .font(LDFont.medium04)
                    .foregroundColor(LDColor.color2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(4)
            } else {
                Text("작품 설명이 없습니다.")
                    .font(LDFont.medium04)
                    .foregroundColor(LDColor.color2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: ArchiveImageConstants.animationThreshold)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 44)
    }
}

// MARK: - 감상 탭
extension ArtReactionSendView {
    fileprivate var reactionTabSection: some View {
        VStack(alignment: .leading, spacing: 36) {
            // 나의 감상
            MessageEditor

            Spacer(minLength: ArchiveImageConstants.animationThreshold)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 40)
    }

    @ViewBuilder
    private var MessageEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("나의 감상")
                .font(LDFont.heading04)
                .foregroundColor(LDColor.color1)

            VStack(alignment: .trailing, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LDColor.color5)
                        .frame(height: 123)

                    if viewModel.message.isEmpty && !isMessageFieldFocused {
                        Text("작품에 대한 생각을 자유롭게 적어보세요.")
                            .font(LDFont.regular02)
                            .foregroundColor(LDColor.color3)
                            .padding(.top, 12)
                            .padding(.leading, 14)
                    }

                    VStack(spacing: 14) {
                        TextEditor(text: $viewModel.message)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .tint(LDColor.gray5)
                            .padding(.top, 3)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .frame(height: 84)
                            .focused($isMessageFieldFocused)
                            .onChange(of: viewModel.message) { newValue in
                                viewModel.updateMessage(newValue: newValue)
                            }
                        HStack {
                            Spacer()
                            Text("\(viewModel.message.count)/\(viewModel.limit)")
                                .font(LDFont.medium04)
                                .foregroundColor(LDColor.color3)
                                .padding(.trailing, 14)
                                .padding(.bottom, 10)
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(LDColor.color6.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

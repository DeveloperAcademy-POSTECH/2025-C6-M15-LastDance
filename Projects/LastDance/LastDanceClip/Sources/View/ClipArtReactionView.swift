//
//  ClipArtworkDetailView.swift
//  LastDance
//
//  Created by 배현진 on 11/10/25.
//

import SwiftUI

struct ClipArtReactionView: View {
    let artworkId: Int
    let exhibitionId: Int
    
    @StateObject private var viewModel: ClipArtReactionViewModel
    @EnvironmentObject private var router: ClipNavigationRouter
    @State private var selectedTab: ArtReactionTab = .artwork
    @State private var scrollOffset: CGFloat = 0
    @FocusState private var isMessageFieldFocused: Bool

    init(artworkId: Int, exhibitionId: Int) {
        self.artworkId = artworkId
        self.exhibitionId = exhibitionId
        _viewModel = StateObject(
            wrappedValue: ClipArtReactionViewModel(
                artworkId: artworkId,
                exhibitionId: exhibitionId
            )
        )
    }
    
    var body: some View {
        // 스크롤에 따라 이미지 크기 조정
        let imageHeight = max(100, 388 - scrollOffset * 1.5)
        let imageWidth = max(150, 281 - (388 - imageHeight) * 0.76)
        
        ZStack(alignment: .top) {
            // 데이터가 로드될 때까지는 로딩만
            if viewModel.isLoaded {
                // 스크롤 가능한 콘텐츠 영역
                ScrollViewObserver(scrollOffset: $scrollOffset) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 36)
                        
                        // 작품 이미지
                        if let imageURLString = viewModel.artwork?.thumbnailURL {
                            CachedImage(
                                imageURLString,
                                targetSize: .init(width: imageWidth, height: imageHeight)
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
                        
                        // 스크롤 안에 들어오는 탭바 (고정 탭바와 겹치지 않게 투명도 조정)
                        TabBarView(selectedTab: $selectedTab)
                            .padding(.top, 23)
                            .opacity(viewModel.isTabBarFixed(for: scrollOffset) || isMessageFieldFocused ? 0 : 1)
                        
                        // 탭별 콘텐츠
                        if selectedTab == .artwork {
                            artworkSection
                        } else {
                            reactionInputSection
                        }
                    }
                }
                .background(LDColor.color6)
                
            } else {
                // 처음 로딩 상태
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .background(LDColor.color6)
            }
            
            // 최상단 고정 탭바
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 36)
                    .background(LDColor.color6)
                
                TabBarView(selectedTab: $selectedTab)
                    .background(LDColor.color6)
            }
            // 고정 탭바 표시 조건: 스크롤 임계값 도달 OR 메시지 필드에 포커스
            .opacity((viewModel.isTabBarFixed(for: scrollOffset) || isMessageFieldFocused) ? 1 : 0)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            // 하단 버튼
            VStack {
                Spacer()
                if selectedTab == .reaction {
                    BottomButton(
                        text: "전송하기",
                        isEnabled: viewModel.hasText,
                        action: { buttonAction() }
                    )
                    .background(LDColor.color6)
                }
            }
        }
        .task {
            await viewModel.loadArtwork()
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    private func buttonAction() {
        Task { @MainActor in
            if await viewModel.sendReaction() {
                router.push(.complete)
            } else {
                // TODO: - 전송 실패 알럿 띄우기 (버튼 throttle 함께 처리)
            }
        }
    }
    
    // MARK: - 작품 탭
    private var artworkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.artwork?.title ?? "작품명")
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(LDColor.color1)
            
            if let artistName = viewModel.artistName {
                HStack {
                    Text(artistName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(LDColor.color1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black, lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(LDColor.color6)
                                )
                        )
                    Spacer()
                }
            } else {
                HStack {
                    Text("작자미상")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(LDColor.color1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black, lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(LDColor.color6)
                                )
                        )
                    Spacer()
                }
            }
            
            Rectangle()
                .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [4]))
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.4))
            
            if let desc = viewModel.artwork?.descriptionText, !desc.isEmpty {
                Text("작품 설명")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.top, 12)
                
                Text(desc)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(LDColor.color2)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("작품 설명이 없습니다.")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .padding(.top, 12)
            }
            
            Spacer(minLength: 600)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 40)
    }
    
    // MARK: - 감상 탭
    private var reactionInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("메시지")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LDColor.color5)
                    .frame(height: 123)
                
                if viewModel.message.isEmpty && !isMessageFieldFocused {
                    Text("작품에 대한 생각을 자유롭게 적어보세요.")
                        .font(.system(size: 16))
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
                            viewModel.updateMessage(newValue)
                        }
                    HStack {
                        Spacer()
                        Text("\(viewModel.message.count)/\(viewModel.limit)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(LDColor.color3)
                            .padding(.trailing, 14)
                            .padding(.bottom, 10)
                    }
                }
            }
            
            Spacer(minLength: 300)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
}

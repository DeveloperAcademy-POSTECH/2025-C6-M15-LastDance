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
    @State private var selectedTab: ArtReactionTab = .artwork
    @State private var scrollOffset: CGFloat = 0

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
        let imageHeight = max(200, 414 - scrollOffset * 0.5)
        let imageWidth = max(150, 305 - (414 - imageHeight) * 0.76)
        
        VStack(spacing: 0) {
            Color.clear
                .frame(height: 36)
                .background(Color.white)
            
            // 고정 탭바
            if viewModel.isTabBarFixed(for: scrollOffset) {
                TabBarView(selectedTab: $selectedTab)
                    .background(Color.white)
            }
            
            // 데이터가 로드될 때까지는 로딩만
            if viewModel.isLoaded {
                ScrollViewObserver(scrollOffset: $scrollOffset) {
                    VStack(spacing: 0) {
                        // 작품 이미지
                        if let imageURLString = viewModel.artwork?.thumbnailURL,
                           let url = URL(string: imageURLString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: imageWidth, height: imageHeight)
                            .clipped()
                            .cornerRadius(24)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: imageWidth, height: imageHeight)
                                .cornerRadius(24)
                                .overlay(
                                    Text("이미지 없음")
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        // 스크롤 안에 들어오는 탭바
                        if !viewModel.isTabBarFixed(for: scrollOffset) {
                            TabBarView(selectedTab: $selectedTab)
                                .padding(.top, 24)
                        } else {
                            TabBarView(selectedTab: $selectedTab)
                                .padding(.top, 24)
                                .hidden()
                        }
                        
                        // 탭별 콘텐츠
                        if selectedTab == .artwork {
                            artworkSection
                        } else {
                            reactionInputSection
                        }
                    }
                }
                .background(Color.white)
            } else {
                // 처음 로딩 상태
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .background(Color.white)
            }
            
            if selectedTab == .reaction {
                ClipBottomButton(
                    text: "전송하기",
                    isEnabled: viewModel.hasText,
                    action: viewModel.sendReaction
                )
            }
        }
        .task {
            await viewModel.loadArtwork()
        }
    }
    
    // MARK: - 작품 탭
    private var artworkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.artwork?.title ?? "작품명")
                .font(.system(size: 21, weight: .semibold))
                .foregroundColor(Color.black)
            
            if let artistName = viewModel.artistName {
                HStack {
                    Text(artistName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.color1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black, lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white)
                                )
                        )
                    Spacer()
                }
            } else {
                HStack {
                    Text("작자미상")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.color1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black, lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white)
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
                    .foregroundColor(Color.black.opacity(0.8))
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
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.06))
                    .frame(minHeight: 128, maxHeight: 152)
                
                if viewModel.message.isEmpty {
                    Text("작품에 대한 생각을 자유롭게 적어보세요.")
                        .foregroundColor(Color.gray.opacity(0.6))
                        .padding(.top, 12)
                        .padding(.leading, 14)
                }
                
                TextEditor(text: $viewModel.message)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 128, maxHeight: 152)
                    .onChange(of: viewModel.message) { newValue in
                        viewModel.updateMessage(newValue)
                    }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.05))
            )
            
            HStack {
                Spacer()
                Text("\(viewModel.message.count)/\(viewModel.limit)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer(minLength: 300)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 40)
    }
}

//
//  ArtReactionView.swift
//  LastDance
//
//  Created by 광로 on 10/20/25.
//

import SwiftUI
import UIKit

struct ArtReactionView: View {
    let artwork: Artwork
    let artist: Artist?

    @StateObject private var viewModel: ArtReactionViewModel
    @EnvironmentObject private var router: NavigationRouter
    @State private var selectedTab: ArtReactionTab = .artwork
    @State private var scrollOffset: CGFloat = 0

    init(artwork: Artwork, artist: Artist?) {
        self.artwork = artwork
        self.artist = artist
        _viewModel = StateObject(wrappedValue: ArtReactionViewModel(artworkId: artwork.id))
    }

    var body: some View {
        VStack(spacing: 0) {
            // 고정된 탭 바
            if viewModel.isTabBarFixed(for: scrollOffset) {
                TabBarView(selectedTab: $selectedTab)
                    .background(Color.white)
                    .padding(.top, 0)
            }
            // 스크롤 가능한 콘텐츠
            ScrollViewObserver(scrollOffset: $scrollOffset) {
                VStack(spacing: 0) {
                    // 작품 이미지
                    if let imageURLString = artwork.thumbnailURL,
                        let imageURL = URL(string: imageURLString)
                    {
                        AsyncImage(url: imageURL) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(
                            width: viewModel.imageWidth(for: scrollOffset),
                            height: viewModel.imageHeight(for: scrollOffset)
                        )
                        .clipped()
                        .cornerRadius(24)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(
                                width: viewModel.imageWidth(for: scrollOffset),
                                height: viewModel.imageHeight(for: scrollOffset)
                            )
                            .overlay(Text("이미지 없음"))
                            .cornerRadius(24)
                    }
                    // 탭 바
                    if !viewModel.isTabBarFixed(for: scrollOffset) {
                        TabBarView(selectedTab: $selectedTab)
                            .padding(.top, 24)
                    }
                    // 탭 콘텐츠
                    ZStack {
                        // 작품 정보 탭
                        VStack(alignment: .leading, spacing: 16) {
                            Text(artwork.title)
                                .font(Font.custom("Pretendard", size: 20).weight(.semibold))
                                .foregroundColor(LDColor.color1)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if let artistName = artist?.name {
                                HStack {
                                    Text(artistName)
                                        .font(Font.custom("Pretendard", size: 16).weight(.medium))
                                        .foregroundColor(LDColor.color6)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(LDColor.color1)
                                        .cornerRadius(20)

                                    Spacer()
                                }
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
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 44)
                        .opacity(selectedTab == .artwork ? 1 : 0)

                        // 감상 탭
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .frame(maxWidth: .infinity, minHeight: 200)
                                    .padding(.top, 24)
                            } else if viewModel.reactions.isEmpty {
                                VStack(spacing: 16) {
                                    Text("아직 등록된 감상이 없습니다")
                                        .font(Font.custom("Pretendard", size: 16))
                                        .foregroundColor(LDColor.color2)

                                    Spacer(minLength: 400)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                            } else {
                                VStack(alignment: .leading, spacing: 24) {
                                    ForEach(viewModel.reactions, id: \.id) { reaction in
                                        VStack(alignment: .leading, spacing: 16) {
                                            // 감정 태그 섹션
                                            if !reaction.tags.isEmpty {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    Text("감정 태그")
                                                        .font(LDFont.heading04)
                                                        .foregroundColor(LDColor.color1)

                                                    ScrollView(.horizontal, showsIndicators: false)
                                                    {
                                                        HStack {
                                                            ForEach(reaction.tags, id: \.self) {
                                                                tagInfo in
                                                                ReactionTag(
                                                                    text: tagInfo.name,
                                                                    color: Color(
                                                                        hex: tagInfo.colorHex)
                                                                )
                                                                .applyShadow(LDShadow.shadow1)
                                                                .padding(.vertical, 10)
                                                                .padding(.horizontal, 2)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            // 감상평 섹션
                                            if let comment = reaction.comment, !comment.isEmpty {
                                                VStack(alignment: .leading, spacing: 12) {
                                                    Text("감상평")
                                                        .font(LDFont.heading04)
                                                        .foregroundColor(LDColor.color1)
                                                    Text(comment)
                                                        .font(LDFont.medium04)
                                                        .foregroundColor(LDColor.color2)
                                                        .lineSpacing(4)
                                                        .frame(
                                                            maxWidth: .infinity, alignment: .leading
                                                        )
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 40)
                            }
                        }
                        .opacity(selectedTab == .reaction ? 1 : 0)
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
                viewModel.loadReactions()
            }
        }
        .navigationBarBackButtonHidden()
    }
}

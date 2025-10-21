//
//  ArchiveView.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftData
import SwiftUI

struct ArchiveView: View {
    let exhibitionId: Int
    
    @StateObject private var viewModel: ArchiveViewModel
    @EnvironmentObject private var router: NavigationRouter
    
    init(exhibitionId: Int) {
        self.exhibitionId = exhibitionId
        _viewModel = StateObject(
            wrappedValue: ArchiveViewModel(exhibitionId: exhibitionId)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ArchiveHeaderView {
                router.popLast()
            }
            .padding(.bottom, 12)
            
            ExhibitionTitleView(title: viewModel.exhibitionTitle)
            
            ArtworkCountView(count: viewModel.reactedArtworksCount)
                .padding(.bottom, -2)
          
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    BackGround(geometry: geometry)

                    ScrollView {
                        VStack(spacing: 0) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .frame(maxWidth: .infinity, minHeight: 400)
                            } else if viewModel.hasArtworks {
                                ArtworkGridView(
                                    artworks: viewModel.reactedArtworks,
                                    getRotationAngle: viewModel.getRotationAngle
                                )
                            } else {
                                ArchiveEmptyStateView {
                                    router.push(.camera)
                                }
                            }
                            
                            Color.clear
                                .frame(height: 600)
                        }
                        .frame(minHeight: geometry.size.height + 400)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .mask(
                    LinearGradient(
                        colors: [
                            Color.black,
                            Color.black,
                            Color.black,
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [LDColor.color6, LDColor.color6]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .safeAreaInset(edge: .bottom) {
            CameraActionButtonView {
                router.push(.camera)
            }
        }
    }
}

struct ArchiveHeaderView: View {
    let onClose: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
            }
            Spacer()
        }
        .padding(.horizontal, 13)
        .padding(.top, 20)
    }
}

struct ExhibitionTitleView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(LDFont.heading02)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 12)
    }
}

struct ArtworkCountView: View {
    let count: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("현재까지 촬영한 이미지")
                .font(LDFont.regular02)
                .foregroundColor(LDColor.gray5)
            Text("\(count)개의 작품")
                .font(LDFont.heading04)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 25)
    }
}

struct ArtworkGridView: View {
    let artworks: [Artwork]
    let getRotationAngle: (Int) -> Double
    
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 31),
                GridItem(.flexible(), spacing: 31)
            ],
            spacing: 24
        ) {
            ForEach(Array(artworks.enumerated()), id: \.element.id) { index, artwork in
                if let urlString = artwork.thumbnailURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 157, height: 213)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 157, height: 213)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .rotationEffect(.degrees(getRotationAngle(index)))
                                .applyShadow(LDShadow.shadow4)
                        case .failure:
                            // TODO: - 실패 시 대체 이미지 넣어주기
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 157, height: 213)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // TODO: - URL 없을 때 대체 이미지 넣어주기
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 157, height: 213)
                        .foregroundColor(.gray)
                }
            }

        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct ArchiveEmptyStateView: View {
    let onAddTap: () -> Void
    
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 31),
                GridItem(.flexible(), spacing: 31)
            ],
            spacing: 24
        ) {
            Button(action: onAddTap) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LDColor.color6)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(LDColor.gray8)
                }
                .frame(width: 157, height: 213)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LDColor.gray8, style: StrokeStyle(lineWidth: 1.4, dash: [8]))
                )
                .rotationEffect(.degrees(-4))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
}

struct CameraActionButtonView: View {
    let action: () -> Void
    @State private var showTooltip: Bool
    
    init(action: @escaping () -> Void) {
        self.action = action
        // 첫 리액션 등록 전이면 툴팁 표시
        _showTooltip = State(initialValue: !UserDefaults.standard.bool(forKey: .hasRegisteredFirstReaction))
    }
    
    var body: some View {
        VStack(spacing: 22) {
            // 툴팁
            ZStack {
                if showTooltip {
                    TooltipView(text: "마음에 드는 작품을 찾아\n사진을 찍어보세요!")
                        .offset(x: 80, y: 0)
                        .transition(.opacity)
                }
            }
            .frame(height: 50)
            // 촬영 버튼
            Button(action: action) {
                Image("Aperture")
                    .resizable()
                    .frame(width: 38, height: 38)
                    .foregroundColor(LDColor.color6)
            }
            .frame(width: 80, height: 80)
            .background(Color.black)
            .clipShape(Circle())
        }
        .padding(.bottom, 40)
    }
}

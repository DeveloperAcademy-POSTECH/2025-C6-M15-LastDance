//
//  ArchiveView.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftUI
import SwiftData

struct ArchiveView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel: ArchiveViewModel
    
    let exhibitionId: String
    
    init(exhibitionId: String) {
        self.exhibitionId = exhibitionId
        _viewModel = StateObject(wrappedValue: ArchiveViewModel(exhibitionId: exhibitionId))
    }
    
    var body: some View {
        VStack(spacing: -12) {
            ArchiveHeaderView {
                router.popLast()
            }
            .padding(.bottom, 24)
            
            ExhibitionTitleView(title: viewModel.exhibitionTitle)
            
            ArtworkCountView(count: viewModel.capturedArtworksCount)
                .padding(.bottom, 10)
            
            GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        // 고정 배경 (화면에 맞게)
                        Image("bauhausArt08")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: geometry.size.height * 2.5)
                            .clipped()
                            .offset(x: 0 ,y: -180)
                            .opacity(0.6)
                            .overlay(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: .white.opacity(0), location: 0.00),
                                        Gradient.Stop(color: .white.opacity(0.7), location: 1.00),
                                    ],
                                    startPoint: UnitPoint(x: 0.456, y: 0.5),
                                    endPoint: UnitPoint(x: 0, y: 0.5)
                                )
                            )
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                        .frame(maxWidth: .infinity, minHeight: 400)
                                } else if viewModel.hasArtworks {
                                    ArtworkGridView(
                                        artworks: viewModel.capturedArtworks,
                                        getRotationAngle: viewModel.getRotationAngle
                                    )
                                } else {
                                    ArchiveEmptyStateView {
                                        router.push(.camera)
                                    }
                                }
                                
                                // 충분한 스크롤 공간 (배경 페이드를 보기 위해)
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
                gradient: Gradient(colors: [Color.white, Color.white]),
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
            .font(.system(size: 22, weight: .semibold))
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
                .font(.custom("Pretendard", size: 18))
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.35))
            Text("\(count)개의 작품")
                .font(.custom("Pretendard", size: 18))
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 25)
    }
}

struct ArtworkGridView: View {
    let artworks: [CapturedArtwork]
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
                Image(artwork.localImagePath)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 157, height: 213)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .rotationEffect(.degrees(getRotationAngle(index)))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
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
                        .fill(Color.white)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(Color(red: 0.88, green: 0.88, blue: 0.88))
                }
                .frame(width: 157, height: 213)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.88, green: 0.88, blue: 0.88), style: StrokeStyle(lineWidth: 1.4, dash: [8]))
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
    @State private var showTooltip = true
    
    var body: some View {
        VStack(spacing: 22) {
            // 툴팁 공간 (고정 높이)
            ZStack {
                if showTooltip {
                    TooltipView(text: "마음에 드는 작품을 찾아\n사진을 찍어보세요!")
                        .offset(x: 80, y: 0)
                        .transition(.opacity)
                }
            }
            .frame(height: 50)
            // Aperture 버튼 (중앙 고정)
            Button(action: action) {
                Image("Aperture")
                    .resizable()
                    .frame(width: 38, height: 38)
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            .background(Color.black)
            .clipShape(Circle())
        }
        .padding(.bottom, 40)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showTooltip = false
                }
            }
        }
    }
}


//
//  ArchiveView.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftUI
import SwiftData

struct ArchiveView: View {
    @StateObject private var viewModel = ArchiveViewModel()
    @EnvironmentObject private var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 0) {
            ArchiveHeaderView {
                router.popLast()
            }
            
            ExhibitionTitleView(title: viewModel.exhibitionTitle)
            
            ArtworkCountView(count: viewModel.capturedArtworksCount)
            
            ScrollView {
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
                    ArchiveEmptyStateView()
                }
            }
        }
        .background(Color.white)
        .safeAreaInset(edge: .bottom) {
            BottomButton(text: "촬영하기") {
                router.push(.camera)
            }
        }
        .onAppear {
            viewModel.loadCurrentExhibition()
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
            Text("관람중")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 58, height: 24)
                .background(Color.black)
                .cornerRadius(99)
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
            .padding(.top, 15)
    }
}

struct ArtworkCountView: View {
    let count: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
    var body: some View {
        Text("마음에 드는 작품을 찾아\n사진을 찍어보세요!")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color(red: 0.81, green: 0.81, blue: 0.81))
            .multilineTextAlignment(.center)
            .lineSpacing(8)
            .frame(maxWidth: .infinity, minHeight: 400)
    }
}

#Preview {
    ArchiveView()
        .environmentObject(NavigationRouter())
        .modelContainer(SwiftDataManager.shared.container!)
}

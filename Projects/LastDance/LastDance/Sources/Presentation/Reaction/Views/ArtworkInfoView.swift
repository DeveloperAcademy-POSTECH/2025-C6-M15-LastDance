//
//  ArtworkInfoView.swift
//  LastDance
//
//  Created by 신얀 on 10/13/25.
//

import SwiftUI
import SwiftData

struct ArtworkInfoView: View {
    let artworkId: Int
    @Query private var allArtworks: [Artwork]
    @Query private var allArtists: [Artist]

    private var artwork: Artwork? {
        allArtworks.first { $0.id == artworkId }
    }

    private var artist: Artist? {
        guard let artistId = artwork?.artistId else { return nil }
        return allArtists.first { $0.id == artistId }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 이미지 영역
            if let thumbnailURL = artwork?.thumbnailURL,
               thumbnailURL.hasPrefix("http")
            {
                // 실제 URL인 경우
                AsyncImage(url: URL(string: thumbnailURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 343)
                }
                .frame(maxHeight: 343)
                .clipped()
            } else if let imageName = artwork?.thumbnailURL {
                // Mock 데이터
                if UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 373)
                        .clipped()
                } else {
                    // Mock 이미지가 없는 경우
                    Image(systemName: "photo.artframe")
                        .foregroundColor(.gray)
                        .frame(height: 343)
                }
            } else {
                // thumbnailURL이 없는 경우
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 343)
            }

            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.97, green: 0.97, blue: 0.97).opacity(0),
                    Color(red: 0.97, green: 0.97, blue: 0.97)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )

            // 작품 정보 영역
            VStack(alignment: .leading, spacing: 8) {
                Text(artwork?.title ?? "작품 제목")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(artist?.name ?? "알 수 없는 작가")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 30)
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}

#Preview {
    ArtworkInfoView(artworkId: 1)
}

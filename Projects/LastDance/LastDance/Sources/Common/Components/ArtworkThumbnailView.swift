//
//  ArtworkThumbnailView.swift
//  LastDance
//
//  Created by donghee on 11/11/25.
//

import SwiftUI

/// 작품 썸네일 이미지를 표시하는 재사용 가능한 컴포넌트
struct ArtworkThumbnailView: View {
    let thumbnailURL: String?
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    init(
        thumbnailURL: String?,
        width: CGFloat = 155,
        height: CGFloat = 219,
        cornerRadius: CGFloat = 0
    ) {
        self.thumbnailURL = thumbnailURL
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Group {
            if let thumbnailURLString = thumbnailURL,
               let url = URL(string: thumbnailURLString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderView
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: width, height: height)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    case .failure:
                        placeholderView
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderView
                    .overlay(
                        Text("이미지 없음")
                            .foregroundColor(.gray)
                    )
            }
        }
    }

    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
    }
}

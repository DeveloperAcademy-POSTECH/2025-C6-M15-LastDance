//
//  ArtworkBackgroundView.swift
//  LastDance
//
//  Created by donghee on 11/10/25.
//

import SwiftUI

/// 작품 배경 이미지 뷰 (그라데이션 오버레이 포함)
struct ArtworkBackgroundView: View {
    let artwork: Artwork?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 이미지 영역
            CachedImage(artwork?.thumbnailURL)
                .aspectRatio(3 / 4, contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: 393)
                .clipped()

            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [
                    LDColor.color5.opacity(0),
                    LDColor.color5,
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 150)  // 하단 150pt만 그라데이션 적용
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .offset(y: -35)
        .ignoresSafeArea(.container, edges: .top)
    }
}

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
                .aspectRatio(contentMode: .fill)
                .frame(maxHeight: 393)
                .clipped()

            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [
                    LDColor.color5.opacity(0),
                    LDColor.color5,
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .offset(y: -35)
        .ignoresSafeArea(.container, edges: .top)
    }
}

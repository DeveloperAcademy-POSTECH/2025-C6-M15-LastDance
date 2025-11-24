//
//  ArtistEmojiPopupView.swift
//  LastDance
//
//  Created by donghee on 11/21/25.
//

import SwiftUI

/// 작가 반응 확인뷰에서만 사용되는 이모지 팝업
struct EMojiPopupView: View {
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(ReactionConstants.emojiAssets, id: \.self) { assetName in
                Button(action: {
                    onSelect(assetName)
                }) {
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .padding(1)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.white)
        .cornerRadius(40)
        .shadow(color: .black.opacity(0.25), radius: 6, x: 1, y: 3)
    }
}

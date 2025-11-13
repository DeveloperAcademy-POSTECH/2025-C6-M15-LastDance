//
//  FloatingBubble.swift
//  LastDance
//
//  Created by 배현진 on 11/14/25.
//
import SwiftUI

struct FloatingBubble: View {
    let text: String
    /// 말풍선 방향 선택
    let tailSide: BubbleTailSide
    /// true면 아래에서 위로, false면 위에서 아래로 시작
    let startsDown: Bool
    /// 이 말풍선이 사용할 최대 가로폭 (좌/우 서로 안 겹치게 나눌 때 사용)
    let maxWidth: CGFloat

    @State private var bob = false
    private let travel: CGFloat = 4
    private let duration: Double = 1.0

    private var imageName: String {
        tailSide == .left ? "LeftBubble" : "RightBubble"
    }

    /// 왼쪽은 항상 더 위, 오른쪽은 항상 더 아래에 있도록 기준 오프셋
    private var baseYOffset: CGFloat {
        switch tailSide {
        case .left:  return -24
        case .right: return +24
        }
    }

    var body: some View {
        let startOffset: CGFloat = startsDown ? -travel : +travel
        let endOffset: CGFloat   = startsDown ? +travel : -travel

        ZStack {
            Image(imageName)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: maxWidth)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(LDColor.color1)
                .lineLimit(1)
                .padding(.vertical, 4)
                .frame(maxWidth: maxWidth * 0.85, alignment: .center)
        }
        .offset(y: baseYOffset + (bob ? endOffset : startOffset))
        .animation(
            .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
            value: bob
        )
        .onAppear { bob = true }
    }
}

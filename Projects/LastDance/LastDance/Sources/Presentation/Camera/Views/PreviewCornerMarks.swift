//
//  PreviewCornerMarks.swift
//  LastDance
//
//  Created by 배현진 on 10/15/25.
//

import SwiftUI

/// 4개 모서리에 L-자 모양 코너 마크를 그려주는 오버레이
private struct PreviewCornerMarks: View {
    var length: CGFloat = 22  // 각 코너의 선 길이
    var lineWidth: CGFloat = 3  // 선 두께
    var color: Color = LDColor.color6  // 선 색
    var inset: CGFloat = 6  // 프리뷰 테두리로부터 안쪽 여백

    var body: some View {
        GeometryReader { proxy in
            let proxyWidth = proxy.size.width
            let proxyHeight = proxy.size.height
            let proxyLength = min(length, min(proxyWidth, proxyHeight) / 2)  // 너무 큰 값 방지

            Canvas { ctx, _ in
                var path = Path()

                // Top-Left
                path.move(to: CGPoint(x: inset, y: inset + proxyLength))
                path.addLine(to: CGPoint(x: inset, y: inset))
                path.addLine(to: CGPoint(x: inset + proxyLength, y: inset))

                // Top-Right
                path.move(to: CGPoint(x: proxyWidth - inset - proxyLength, y: inset))
                path.addLine(to: CGPoint(x: proxyWidth - inset, y: inset))
                path.addLine(to: CGPoint(x: proxyWidth - inset, y: inset + proxyLength))

                // Bottom-Left
                path.move(to: CGPoint(x: inset, y: proxyHeight - inset - proxyLength))
                path.addLine(to: CGPoint(x: inset, y: proxyHeight - inset))
                path.addLine(to: CGPoint(x: inset + proxyLength, y: proxyHeight - inset))

                // Bottom-Right
                path.move(to: CGPoint(x: proxyWidth - inset - proxyLength, y: proxyHeight - inset))
                path.addLine(to: CGPoint(x: proxyWidth - inset, y: proxyHeight - inset))
                path.addLine(
                    to: CGPoint(x: proxyWidth - inset, y: proxyHeight - inset - proxyLength))

                ctx.stroke(path, with: .color(color), lineWidth: lineWidth)
            }
        }
        .allowsHitTesting(false)  // 터치 통과
        .accessibilityHidden(true)
    }
}

// Camera에서만 사용되는 기능으로, Common으로 분리하지 않았습니다.
extension View {
    /// 뷰파인더 코너 마크 오버레이
    func viewfinderCorners(
        length: CGFloat = 22,
        lineWidth: CGFloat = 3,
        color: Color = LDColor.color6,
        inset: CGFloat = 6
    ) -> some View {
        overlay(
            PreviewCornerMarks(
                length: length,
                lineWidth: lineWidth,
                color: color,
                inset: inset
            )
        )
    }
}

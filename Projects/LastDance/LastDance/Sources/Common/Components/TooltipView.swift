//
//  TooltipView.swift
//  LastDance
//
//  Created by 광로 on 10/19/25.
//

import SwiftUI

struct TooltipView: View {
    let text: String

    var body: some View {
        // 캡슐 모양 툴팁
        Text(text)
            .font(LDFont.regular03)
            .foregroundColor(LDColor.color6)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                RoundedCornerRectangle(cornerRadius: 12)
                    .fill(Color.black)
            )
    }
}

struct RoundedCornerRectangle: Shape {
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // 왼쪽 위 둥근 모서리부터 시작
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        // 상단 직선 → 오른쪽 위 둥근 모서리
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}

#Preview {
    TooltipView(text: "작품을 모을 수 있어요!")
        .padding()
}

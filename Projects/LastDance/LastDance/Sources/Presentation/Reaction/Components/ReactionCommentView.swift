//
//  Untitled.swift
//  LastDance
//
//  Created by 배현진 on 11/24/25.
//

import SwiftUI

/// 작가 flow: 반응 보기에서 댓글 텍스트 + 더보기/접기
struct ReactionCommentView: View {
    let comment: String
    let isExpanded: Bool
    let onToggleExpand: () -> Void

    @State private var isTruncated: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(comment)
                .font(LDFont.medium03)
                .foregroundColor(LDColor.color1)
                .lineSpacing(6)
                .lineLimit(isExpanded ? nil : 3)
                .background(
                    ZStack {
                        // 3줄 제한 높이
                        MeasuringText(
                            comment,
                            lineLimit: 3,
                            kind: .limited
                        )

                        // 전체 텍스트 높이
                        MeasuringText(
                            comment,
                            lineLimit: nil,
                            kind: .full
                        )
                    }
                )
                .onPreferenceChange(CommentHeightPreferenceKey.self) { values in
                    if let limited = values[.limited],
                        let full = values[.full]
                    {
                        isTruncated = full - limited > 1
                    }
                }

            if isTruncated {
                Button(action: onToggleExpand) {
                    Text(isExpanded ? "접기" : "더보기")
                        .font(LDFont.medium05)
                        .foregroundColor(LDColor.color3)
                }
            }
        }
    }
}

// MARK: - 내부 전용 Helper 뷰 & PreferenceKey

private enum CommentHeightKind: Hashable {
    case limited
    case full
}

private struct CommentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: [CommentHeightKind: CGFloat] = [:]

    static func reduce(
        value: inout [CommentHeightKind: CGFloat],
        nextValue: () -> [CommentHeightKind: CGFloat]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

private struct MeasuringText: View {
    let text: String
    let lineLimit: Int?
    let kind: CommentHeightKind

    init(_ text: String, lineLimit: Int?, kind: CommentHeightKind) {
        self.text = text
        self.lineLimit = lineLimit
        self.kind = kind
    }

    var body: some View {
        Text(text)
            .font(LDFont.medium03)
            .lineSpacing(6)
            .lineLimit(lineLimit)
            .fixedSize(horizontal: false, vertical: true)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: CommentHeightPreferenceKey.self,
                        value: [kind: proxy.size.height]
                    )
                }
            )
            .hidden()
    }
}

//
//  TagListView.swift
//  LastDance
//
//  Created by 배현진 on 10/20/25.
//

import SwiftUI

/// Category에 해당하는 Tag 목록 표시하는 뷰
struct TagListView: View {
    let tags: [Tag]
    let selected: Set<Int>
    let color: Color
    let isFull: Bool
    let onTap: (Tag) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(tags) { tag in
                let isOn = selected.contains(tag.id)

                Button {
                    onTap(tag)
                } label: {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)

                        Text(tag.name)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(isOn ? Color.white : Color.white)
                            .shadow(color: isOn ? color.opacity(0.3) : .clear, radius: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                isOn ? .black : .clear,
                                lineWidth: isOn ? 1.6 : 0
                            )
                    )
                }
                .buttonStyle(.plain)
                .disabled(!isOn && isFull)
            }
        }
        .padding(.horizontal, 24)
    }
}

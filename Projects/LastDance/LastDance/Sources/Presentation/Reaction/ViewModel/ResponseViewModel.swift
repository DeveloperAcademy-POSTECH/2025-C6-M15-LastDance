//
//  ResponseViewModel.swift
//  LastDance
//
//  Created by donghee on 10/20/25.
//

import Foundation
import SwiftUI

// MARK: - ReactionData

struct ReactionData: Identifiable {
    let id: String
    let comment: String
    let categories: [String]
}

// MARK: - ResponseViewModel

class ResponseViewModel: ObservableObject {
    @Published var expandedReactions: Set<String> = []
    @Published var showAllReactions: [String: Bool] = [:]

    // 샘플 반응 데이터
    let sampleReactions: [ReactionData] = [
        ReactionData(
            id: "1",
            comment: "마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래...",
            categories: ["강한 메시지가 느껴져요", "감동적이에요", "생각하게 만들어요"]
        ),
        ReactionData(
            id: "2",
            comment: "마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래...",
            categories: ["강한 메시지가 느껴져요", "놀라워요", "생각해볼만해요"]
        ),
        ReactionData(
            id: "3",
            comment: "마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래 남는 작품이다마음에 오래...",
            categories: ["강한 메시지가 느껴져요", "깊이 있어요", "인상적이에요"]
        )
    ]

    func toggleExpandReaction(id: String) {
        if expandedReactions.contains(id) {
            expandedReactions.remove(id)
        } else {
            expandedReactions.insert(id)
        }
    }

    func toggleShowAllReactions(id: String) {
        showAllReactions[id] = !(showAllReactions[id] ?? false)
    }

    func handleExpandToggle(for reaction: ReactionData) {
        let willExpand = !expandedReactions.contains(reaction.id)
        toggleExpandReaction(id: reaction.id)

        if willExpand {
            if !(showAllReactions[reaction.id] ?? false) && reaction.categories.count > 1 {
                toggleShowAllReactions(id: reaction.id)
            }
        } else {
            if showAllReactions[reaction.id] ?? false {
                toggleShowAllReactions(id: reaction.id)
            }
        }
    }

    func displayText(for reaction: ReactionData) -> String {
        if expandedReactions.contains(reaction.id) {
            return reaction.comment
        } else {
            return String(reaction.comment.prefix(100)) + (reaction.comment.count > 100 ? "..." : "")
        }
    }

    func hiddenCount(for reaction: ReactionData) -> Int {
        reaction.categories.count > 1 ? reaction.categories.count - 1 : 0
    }
}

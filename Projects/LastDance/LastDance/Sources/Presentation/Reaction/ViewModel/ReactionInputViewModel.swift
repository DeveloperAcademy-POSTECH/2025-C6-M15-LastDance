//
//  ReactionInputViewModel.swift
//  LastDance
//
//  Created by 배현진, 신얀 on 10/5/25.
//

import SwiftData
import SwiftUI

@MainActor
final class ReactionInputViewModel: ObservableObject {
    @Published var message: String = ""  // 반응을 남기기 위한 textEditor 메세지
    @Published var selectedCategories: Set<String> = []

    let limit = 500 // texteditor 최대 글자수 제한

    // 하단버튼 유효성 검사
    var isSendButtonDisabled: Bool {
        return selectedCategories.isEmpty
    }

    // 텍스트 길이 제한 로직
    func updateMessage(newValue: String) {
        if newValue.count > limit {
            message = String(newValue.prefix(limit))
        } else {
            message = newValue
        }
    }

    // 카테고리 토글 로직
    func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else if selectedCategories.count < 4 {
            selectedCategories.insert(category)
        }
    }

    /// 작품 반응을 저장하는 함수
    func saveReaction(artworkId: String, context: ModelContext, completion: @escaping (Bool) -> Void) {
        guard !selectedCategories.isEmpty else {
            completion(false)
            return
        }

        let reaction = Reaction(
            id: UUID().uuidString,
            artworkId: artworkId,
            userId: "mockUser",
            category: Array(selectedCategories),
            comment: message.isEmpty ? nil : message,
            createdAt: .now
        )

        context.insert(reaction)

        do {
            try context.save()
            message = ""
            selectedCategories.removeAll()
            Log.debug("[ReactionInputViewModel] 저장 완료")
            completion(true)
        } catch {
            Log.debug("[ReactionInputViewModel] 저장 실패: \(error)")
            completion(false)
        }
    }
}

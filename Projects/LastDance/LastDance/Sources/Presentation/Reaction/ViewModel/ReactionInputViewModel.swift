//
//  ReactionInputViewModel.swift
//  LastDance
//
//  Created by 배현진, 신얀 on 10/5/25.
//

import SwiftData
import SwiftUI
import Moya

@MainActor
final class ReactionInputViewModel: ObservableObject {
    @Published var message: String = ""  // 반응을 남기기 위한 textEditor 메세지
    @Published var selectedCategories: Set<String> = []

    let limit = 500 // texteditor 최대 글자수 제한
    private let apiService = ReactionAPIService()

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
    func saveReaction(artworkId: Int, visitorId: Int, visitId: Int, imageUrl: String?, tagIds: [Int], completion: @escaping (Bool) -> Void) {
        guard !tagIds.isEmpty else {
            completion(false)
            return
        }

        let dto = ReactionRequestDto(
            artworkId: artworkId,
            visitorId: visitorId,
            visitId: visitId,
            comment: message.isEmpty ? nil : message,
            imageUrl: imageUrl,
            tagIds: tagIds
        )

        apiService.createReaction(dto: dto) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.message = ""
                    self.selectedCategories.removeAll()
                    Log.debug("[ReactionInputViewModel] API 저장 완료: \(response)")
                    completion(true)
                case .failure(let error):
                    Log.debug("[ReactionInputViewModel] API 저장 실패: \(error)")
                    completion(false)
                }
            }
        }
    }
    
    // TODO: 실제데이터 연동 후 파라미터 교체 예정
    func getReactionsAPI(artworkId: Int) {
        Log.debug("[ArtworkDetailView] 반응 조회 API 테스트 시작")

        apiService.getReactions(artworkId: artworkId, visitorId: nil, visitId: nil) { result in
            switch result {
            case .success(let reactions):
                Log.debug("[ArtworkDetailView] ✅ 반응 조회 성공! 조회된 반응 수: \(reactions.count)")
            case .failure(let error):
                Log.debug("[ArtworkDetailView] ❌ 반응 조회 실패: \(error)")
            }
        }
    }
}

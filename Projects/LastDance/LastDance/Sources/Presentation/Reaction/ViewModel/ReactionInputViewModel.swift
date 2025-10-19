//
//  ReactionInputViewModel.swift
//  LastDance
//
//  Created by 신얀 on 10/15/25.
//

import SwiftData
import SwiftUI
import Moya

@MainActor
final class ReactionInputViewModel: ObservableObject {
    @Published var message: String = ""  // 반응을 남기기 위한 textEditor 메세지
    @Published var selectedCategories: Set<String> = []
    @Published var selectedArtworkTitle: String = ""  // 선택한 작품 제목
    @Published var selectedArtistName: String = ""    // 선택한 작가 이름
    @Published var capturedImage: UIImage?  // 촬영한 이미지
    @Published var categories: [TagCategory] = []

    var selectedArtworkId: Int?  // 선택한 작품 ID (내부 저장용)

    private let dataManager = SwiftDataManager.shared
    let limit = 500 // texteditor 최대 글자수 제한
    private let apiService = ReactionAPIService()
    private let artworkAPIService = ArtworkAPIService()
    private let categoryService = TagCategoryAPIService()
  
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

    /// 인식된 작품의 작품명과 작가 정보를 저장하는 함수
    func setArtworkInfo(artworkTitle: String, artistName: String, artworkId: Int, completion: @escaping (Bool) -> Void) {
        self.selectedArtworkTitle = artworkTitle
        self.selectedArtistName = artistName
        self.selectedArtworkId = artworkId
        Log.debug("작품 정보 설정 - 작품: \(artworkTitle), 작가: \(artistName), ID: \(artworkId)")
        completion(true)
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
                case .success:
                    self.message = ""
                    self.selectedCategories.removeAll()
                    Log.debug("반응 저장 성공")
                    completion(true)
                case .failure(let error):
                    Log.debug("반응 저장 실패: \(error)")
                    completion(false)
                }
            }
        }
    }
    
    // TODO: 실제데이터 연동 후 파라미터 교체 예정
    func getReactionsAPI(artworkId: Int) {
        Log.debug("반응 조회 API 테스트 시작")

        apiService.getReactions(artworkId: artworkId, visitorId: nil, visitId: nil) { result in
            switch result {
            case .success(let reactions):
                Log.debug("반응 조회 성공! 조회된 반응 수: \(reactions.count)")
            case .failure(let error):
                Log.debug("반응 조회 실패: \(error)")
            }
        }
    }

    /// 반응 상세 조회 API 함수
    func getDetailReactionAPI(reactionId: Int) {
        Log.debug("반응 상세 조회 API 테스트 시작 - reactionId: \(reactionId)")

        apiService.getDetailReaction(reactionId: reactionId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    Log.debug("반응 상세 조회 성공!")
                case .failure(let error):
                    Log.debug("반응 상세 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 작품 목록 조회 API 함수
    func fetchArtworks(artistId: Int? = nil, exhibitionId: Int? = nil) {
        Log.debug("작품 목록 조회 API 호출 - artistId: \(String(describing: artistId)), exhibitionId: \(String(describing: exhibitionId))")

        artworkAPIService.getArtworks(artistId: artistId, exhibitionId: exhibitionId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let artworks):
                    Log.debug("작품 목록 조회 성공! 조회된 작품 수: \(artworks.count)")
                case .failure(let error):
                    Log.error("작품 목록 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// 카테고리별 태그 전체 가져오기 함수
    func loadTagsByCategory() {
        categoryService.getTagCategories { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                Log.error("요청 실패: \(error)")
                return

            case .success(let listDtos):
                let group = DispatchGroup()
                var temps: [TagCategory] = []
                var firstError: Error?

                for dto in listDtos {
                    group.enter()
                    self.categoryService.getTagCategory(id: dto.id) { [weak self] detailResult in
                        guard let self else {
                            group.leave()
                            return
                        }
                        defer { group.leave() }

                        switch detailResult {
                        case .success(let detail):
                            temps.append(TagCategoryMapper.toCategory(from: detail))
                        case .failure(let err):
                            firstError = firstError ?? err
                            temps.append(TagCategoryMapper.toCategory(from: dto, tags: []))
                        }
                    }
                }

                group.notify(queue: .main) {
                    self.categories = temps.sorted { $0.id < $1.id }

                    if let err = firstError {
                        Log.warning("일부 실패: \(err.localizedDescription)")
                    } else {
                        Log.info("\(self.categories.count)개 로드 완료")
                    }
                }
            }
        }
    }
}

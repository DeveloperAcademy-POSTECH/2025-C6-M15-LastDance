//
//  ReactionInputViewModel.swift
//  LastDance
//
//  Created by 신얀 on 10/15/25.
//

import Moya
import SwiftData
import SwiftUI

@MainActor
final class ReactionInputViewModel: ObservableObject {
    @Published var message: String = ""  // 반응을 남기기 위한 textEditor 메세지
    @Published var selectedCategories: Set<String> = []
    @Published var selectedArtworkTitle: String = ""  // 선택한 작품 제목
    @Published var selectedArtistName: String = ""    // 선택한 작가 이름
    @Published var capturedImage: UIImage?  // 촬영한 이미지
    @Published var categories: [TagCategory] = []
    @Published var selectedCategoryIds: Set<Int> = []
    @Published var selectedTagIds: Set<Int> = []
    @Published var selectedTagsName: Set<String> = []
    
    let categoryLimit = 2
    let tagLimit = 6
    let limit = 500 // texteditor 최대 글자수 제한

    var selectedArtworkId: Int?  // 선택한 작품 ID (내부 저장용)
    var selectedArtistId: Int?  // 선택한 작가 ID (내부 저장용)

    private let dataManager = SwiftDataManager.shared
    private let apiService = ReactionAPIService()
    private let artworkAPIService = ArtworkAPIService()
    private let categoryService = TagCategoryAPIService()
    private let tagAPIService = TagAPIService()

    // 하단버튼 유효성 검사
    var isSendButtonDisabled: Bool {
        return selectedTagIds.isEmpty
    }
    
    // 선택 개수 충족 검사
    var isFull: Bool {
        selectedTagIds.count >= tagLimit
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
    func setArtworkInfo(artworkTitle: String, artistName: String, artworkId: Int, artistId: Int, completion: @escaping (Bool) -> Void) {
        self.selectedArtworkTitle = artworkTitle
        self.selectedArtistName = artistName
        self.selectedArtworkId = artworkId
        self.selectedArtistId = artistId

        // SwiftData에서 작품의 artistId 업데이트
        dataManager.updateArtworkArtist(artworkId: artworkId, artistId: artistId)

        Log.debug("작품 정보 설정 - 작품: \(artworkTitle), 작가: \(artistName), 작품ID: \(artworkId), 작가ID: \(artistId)")
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
                    
                    // 첫 리액션 등록 플래그 저장
                    if !UserDefaults.standard.bool(forKey: .hasRegisteredFirstReaction) {
                        UserDefaults.standard.set(true, forKey: .hasRegisteredFirstReaction)
                    }
                    
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
    
    func findColorForTag(tagName: String) -> Color {
        for category in categories {
            if category.tags.contains(where: { $0.name == tagName }) {
                return Color(hex: category.colorHex)
            }
        }
        return .gray
    }
}

// MARK: - Category 로직
extension ReactionInputViewModel {
    /// 서버에서 카테고리 + 하위 태그 불러오기
    func loadCategories() {
        Log.debug("🛰️ 카테고리 목록 요청 시작")

        categoryService.getTagCategories { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure(let error):
                Log.error("❌ 카테고리 목록 요청 실패: \(error)")
                return

            case .success(let listDtos):
                let group = DispatchGroup()
                var fetched: [TagCategory] = []
                var firstError: Error?

                for dto in listDtos {
                    group.enter()
                    self.categoryService.getTagCategory(id: dto.id) { detailResult in
                        defer { group.leave() }
                        switch detailResult {
                        case .success(let detailDto):
                            let category = TagCategoryMapper.toCategory(from: detailDto)
                            fetched.append(category)
                        case .failure(let err):
                            firstError = firstError ?? err
                            // 하위 태그 불러오기에 실패하더라도 최소한 이름, 색상은 보여줄 수 있도록
                            let fallback = TagCategoryMapper.toCategory(from: dto, tags: [])
                            fetched.append(fallback)
                        }
                    }
                }

                group.notify(queue: .main) {
                    self.categories = fetched.sorted { $0.id < $1.id }

                    if let err = firstError {
                        Log.warning("⚠️ 일부 카테고리 불러오기 실패: \(err.localizedDescription)")
                    } else {
                        Log.info("✅ 총 \(self.categories.count)개의 카테고리 로드 완료")
                    }
                }
            }
        }
    }

    // MARK: - 선택 관리
    func toggleCategory(_ id: Int) {
        if selectedCategoryIds.contains(id) {
            selectedCategoryIds.remove(id)
            
            // 카테고리 선택 해제 시, 해당 카테고리에 속한 태그들을 선택 해제
            if let category = categories.first(where: { $0.id == id }) {
                let tagsToDeselect = category.tags.map { $0.id }
                selectedTagIds.subtract(tagsToDeselect)
                
                let tagNamesToDeselect = category.tags.map { $0.name }
                selectedTagsName.subtract(tagNamesToDeselect)
            }
        } else if selectedCategoryIds.count < categoryLimit {
            selectedCategoryIds.insert(id)
        }
    }
}

// MARK: - Tag 로직
extension ReactionInputViewModel {
    func loadTagsForSelectedCategories() {
        let group = DispatchGroup()
        var updatedCategories: [TagCategory] = []

        for category in categories {
            group.enter()
            tagAPIService.getTags(categoryId: category.id) { result in
                switch result {
                case .success(let dtoList):
                    let tags = dtoList.map { TagMapper.toTag($0) }
                    let updated = TagCategory(
                        id: category.id,
                        name: category.name,
                        colorHex: category.colorHex,
                        tags: tags
                    )
                    updatedCategories.append(updated)
                case .failure(let error):
                    Log.error("태그 로드 실패 (categoryId: \(category.id)): \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.categories = updatedCategories.sorted { $0.id < $1.id }
            Log.info("✅ 태그 \(updatedCategories.count)개 카테고리 로드 완료")
        }
    }

    // MARK: - 태그 선택 로직
    func toggleTag(_ tag: Tag) {
        if selectedTagIds.contains(tag.id) {
            selectedTagIds.remove(tag.id)
            selectedTagsName.remove(tag.name)
        } else if selectedTagIds.count < tagLimit {
            selectedTagIds.insert(tag.id)
            selectedTagsName.insert(tag.name)
        }
    }
}

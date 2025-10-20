//
//  TagSelectViewModel.swift
//  LastDance
//
//  Created by 배현진 on 10/20/25.
//

import Foundation

@MainActor
final class TagSelectViewModel: ObservableObject {
    @Published var categories: [TagCategory] = []
    @Published var selectedTagIds: Set<Int> = []
    @Published var selectedTagsName: Set<String> = []

    let tagLimit = 6
    private let tagAPIService: TagAPIServiceProtocol

    var isFull: Bool {
        selectedTagIds.count >= tagLimit
    }
    
    init(
        selectedCategories: [TagCategory],
        tagAPIService: TagAPIServiceProtocol = TagAPIService()
    ) {
        self.categories = selectedCategories
        self.tagAPIService = tagAPIService
    }

    // MARK: - 서버 요청
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

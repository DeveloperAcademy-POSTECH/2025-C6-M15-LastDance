//
//  CategorySelectViewModel.swift
//  LastDance
//
//  Created by 배현진 on 10/20/25.
//

import Foundation

@MainActor
final class CategorySelectViewModel: ObservableObject {
    @Published var categories: [TagCategory] = []
    @Published var selectedCategoryIds: Set<Int> = []
    let categoryLimit = 2

    private let categoryService: TagCategoryAPIServiceProtocol

    init(service: TagCategoryAPIServiceProtocol = TagCategoryAPIService()) {
        self.categoryService = service
    }

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
        } else if selectedCategoryIds.count < categoryLimit {
            selectedCategoryIds.insert(id)
        }
    }

    var selectedCategories: [TagCategory] {
        categories.filter { selectedCategoryIds.contains($0.id) }
    }
}

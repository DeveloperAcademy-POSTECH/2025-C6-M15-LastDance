//
//  ArchivingViewModel.swift
//  LastDance
//
//  Created by donghee, 광로 on 10/19/25.
//

import Moya
import SwiftData
import SwiftUI

@MainActor
final class ArchivingViewModel: ObservableObject {
    @Published private(set) var exhibitions: [Exhibition] = []
    @Published var isLoading = false

    private let swiftDataManager = SwiftDataManager.shared
    private let visitorService = VisitorAPIService()
    private let artistService = ArtistAPIService()

    // MARK: - Computed Properties

    var hasExhibitions: Bool {
        !exhibitions.isEmpty
    }

    // MARK: - Public Methods

    func loadExhibitions() {
        isLoading = true
        do {
            exhibitions = try fetchExhibitions()
        } catch {
            Log.error("Failed to load exhibitions: \(error)")
        }
        isLoading = false
    }

    func dateString(for exhibition: Exhibition) -> String {
        return Date.formatShortDate(from: exhibition.startDate)
    }

    /// 서버에 있는 모든 작가 정보 로드 (확인용)
    func loadAllArtists(onComplete _: (() -> Void)? = nil) {
        artistService.getArtists { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    Log.info("Get Artists success. count=\(list.count)")
                case .failure(let error):
                    if let moyaError = error as? MoyaError,
                        let data = moyaError.response?.data,
                        let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                    {
                        let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                        Log.warning("Get Artist validation: \(messages)")
                    } else {
                        Log.error("Get Artist failed: \(error)")
                    }
                }
            }
        }
    }

    /// 서버에 있는 모든 방문객 정보 로드 (확인용)
    func loadVisitorAPI() {
        visitorService.getVisitors { result in
            switch result {
            case .success(let list):
                Log.debug("방문자 수: \(list.count)")
            case .failure(let err):
                Log.debug("목록 실패: \(err)")
            }
        }
    }

    // MARK: - Private Methods

    private func fetchExhibitions() throws -> [Exhibition] {
        guard let container = swiftDataManager.container else {
            throw NSError(
                domain: "ArchivingViewModel", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Container not available"]
            )
        }

        let context = container.mainContext
        let predicate = #Predicate<Exhibition> { exhibition in
            exhibition.isUserSelected == true
        }
        let descriptor = FetchDescriptor<Exhibition>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )

        return try context.fetch(descriptor)
    }
}

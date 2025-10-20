//
//  ArchiveViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftData
import SwiftUI

@MainActor
final class ArchiveViewModel: ObservableObject {
    
    let exhibitionId: Int
    
    @Published var reactedArtworks: [Artwork] = []
    @Published var currentExhibition: Exhibition?
    @Published var isLoading = false

    private let swiftDataManager = SwiftDataManager.shared
    private let reactionApiService = ReactionAPIService()
    private let artworkAPIService = ArtworkAPIService()
    private let exhibitionService = ExhibitionAPIService()
  
    private let exhibitionId: String
    
    var reactedArtworksCount: Int {
        reactedArtworks.count
    }
    var exhibitionTitle: String {
        currentExhibition?.title ?? "전시 정보 없음"
    }
    var hasArtworks: Bool {
        !reactedArtworks.isEmpty
    }
    
    init(exhibitionId: Int) {
        self.exhibitionId = exhibitionId
        loadData()
    }

    func loadData() {
        isLoading = true
        
        // 로컬 전시 로드
        fetchExhibition(by: exhibitionId)

        // 전시 상세(artworks)가 없다면 가져오기
        ensureExhibitionArtworksLoaded(exhibitionId: exhibitionId) { [weak self] in
            guard let self else { return }

            // Visitor ID 로드
            guard let visitorIdStr = UserDefaults.standard.string(forKey: UserDefaultsKey.visitorId.key),
                  let visitorId = Int(visitorIdStr) else {
                Log.warning("Visitor ID 없음")
                isLoading = false
                return
            }

            // 필요한 Artwork 위해 필터링 (해당 Exhibition의 Artworks들 중에서 해당 Visitor가 Reaction 남긴 적 있는 Artwork)
            self.getReactionsAPI(visitorId: visitorId)
        }
    }

    private func ensureExhibitionArtworksLoaded(
        exhibitionId: Int,
        completion: @escaping () -> Void) {
        // 현재 로컬에 전시 정보가 있고, artworks가 이미 채워져 있으면 바로 진행
        if let exhibition = currentExhibition, !exhibition.artworks.isEmpty {
            Log.info("전시(\(exhibition.id))의 작품 \(exhibition.artworks.count)개 로컬에 존재")
            completion()
            return
        }

        // 현재 로컬에 전시 정보가 없으면, 상세 호출로 로컬에 작품을 채운다
        exhibitionService.getDetailExhibition(exhibitionId: exhibitionId) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // 상세 저장이 끝났으니, 다시 로컬에서 Exhibition 최신 상태를 로드
                    self.fetchExhibition(by: exhibitionId)
                    Log.debug("전시 상세 저장 완료. 작품 수: \(self.currentExhibition?.artworks.count ?? 0)")
                    completion()
                case .failure(let error):
                    Log.error("전시 상세 조회 실패: \(error.localizedDescription)")
                    completion()
                }
            }
        }
    }
    
    /// 대각선 효과
    func getRotationAngle(for index: Int) -> Double {
        let angles: [Double] = [-4, 3, 3, -4]  // 좌상, 우상, 좌하, 우하
        return angles[index % angles.count]
    }
    
    /// 현재 전시 정보 가져오기
    func fetchExhibition(by id: Int) {
        let allExhibitions = swiftDataManager.fetchAll(Exhibition.self)
        currentExhibition = allExhibitions.first { $0.id == id }
    }
    
    /// Visitor의 Reaction 목록 가져오기
    func getReactionsAPI(visitorId: Int) {
        reactionApiService.getReactions(
            artworkId: nil,
            visitorId: visitorId,
            visitId: nil) { [weak self] result in
                
            guard let self else { return }
            
            switch result {
            case .success(let reactions):
                Log.debug("전체 반응 수: \(reactions.count)")
                
                // 현재 전시의 작품 id 목록
                guard let exhibition = self.currentExhibition else {
                    Log.error("전시 정보가 없음. 필터링 불가.")
                    isLoading = false
                    return
                }
                
                let exhibitionArtworkIds = Set(exhibition.artworks.map { $0.id })
                
                // 전시에 속한 반응만 필터링
                let filteredReactions = reactions.filter {
                    exhibitionArtworkIds.contains($0.artwork_id)
                }
                Log.info("전시에 해당하는 반응 수: \(filteredReactions.count)")
                
                if filteredReactions.isEmpty {
                    Log.info("해당 전시에 대한 반응이 없습니다.")
                    isLoading = false
                    return
                }
                
                // 해당 artwork 상세 정보 조회 (with DispatchGroup)
                let group = DispatchGroup()
                filteredReactions.forEach { reaction in
                    group.enter()
                    self.fetchArtworkDetail(artworkId: reaction.artwork_id) {
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    Log.info("작품 정보 로드 완료. 총 작품 수: \(self.reactedArtworks.count)")
                    self.isLoading = false
                }
                
            case .failure(let error):
                Log.error("반응 조회 실패: \(error)")
                isLoading = false
            }
        }
    }
    
    /// Artwork 상세 조회
    func fetchArtworkDetail(artworkId: Int, completion: (() -> Void)? = nil) {
        artworkAPIService.getArtworkDetail(artworkId: artworkId) { [weak self] result in
            guard let self else {
                completion?()
                return
            }
            
            switch result {
            case .success(let dto):
                let artwork = ArtworkMapper.mapDtoToModel(dto, exhibitionId: self.exhibitionId)
                
                if !self.reactedArtworks.contains(where: { $0.id == artwork.id }) {
                    self.reactedArtworks.append(artwork)
                    Log.debug("작품 추가: \(artwork.title)")
                }
                
            case .failure(let error):
                Log.error("조회 실패 (id: \(artworkId)): \(error.localizedDescription)")
            }
            
            completion?()
        }
    }
}

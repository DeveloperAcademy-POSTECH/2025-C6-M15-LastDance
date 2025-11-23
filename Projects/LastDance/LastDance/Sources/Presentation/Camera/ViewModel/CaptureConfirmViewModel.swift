//
//  CaptureConfirmViewModel.swift
//  LastDance
//
//  Created by 아우신얀 on 10/20/25.
//

import SwiftUI

@MainActor
final class CaptureConfirmViewModel: ObservableObject {
    @Published var isUploading = false
    @Published var isMatching = false
    @Published var matchResponse: ArtworkMatchResponseDto?
    @Published var topCandidate: ArtworkMatchResultDto?
    @Published var matchedArtworkImage: UIImage?
    @Published var uploadedImageUrl: String?
    @Published var errorMessage: String?
    @Published var showFailAlert: Bool = false
    @Published var matchedArtworkId: Int?
    @Published var matchedArtistId: Int?
    @Published var matchedExhibitions: [ArtworkMatchExhibitionDto] = []
    @Published var currentExhibition: Exhibition?
    @Published var artwork: Artwork?
    @Published var artist: Artist?

    private let imageService: ImageAPIServiceProtocol
    private let artistService: ArtistAPIServiceProtocol
    private let artworkService: ArtworkAPIServiceProtocol
    private let exhibitionService: ExhibitionAPIServiceProtocol
    private let visitHistoriesService: VisitHistoriesAPIServiceProtocol
    private let dataManager = SwiftDataManager.shared

    init(
        imageService: ImageAPIServiceProtocol = ImageAPIService(),
        artistService: ArtistAPIServiceProtocol = ArtistAPIService(),
        artworkService: ArtworkAPIServiceProtocol = ArtworkAPIService(),
        exhibitionService: ExhibitionAPIServiceProtocol = ExhibitionAPIService(),
        visitHistoriesService: VisitHistoriesAPIServiceProtocol = VisitHistoriesAPIService()
    ) {
        self.imageService = imageService
        self.artistService = artistService
        self.artworkService = artworkService
        self.exhibitionService = exhibitionService
        self.visitHistoriesService = visitHistoriesService
    }

    /// 이미지를 S3에 업로드
    func uploadImage(_ image: UIImage, folder: ImageFolder = .reactions) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "이미지 변환 실패"
            Log.warning("UIImage를 Data로 변환 실패")
            return
        }

        isUploading = true
        errorMessage = nil

        imageService.uploadImage(folder: folder, imageData: imageData) { [weak self] result in
            guard let self = self else { return }

            Task { @MainActor in
                self.isUploading = false

                switch result {
                case .success(let response):
                    self.uploadedImageUrl = response.url
                    // UserDefaults에 업로드된 URL 저장
                    UserDefaults.standard.set(
                        response.url, forKey: UserDefaultsKey.uploadedImageUrl.key)
                    Log.info("이미지 업로드 성공: \(response.url)")

                case .failure(let error):
                    self.errorMessage = "업로드 실패: \(error.localizedDescription)"
                    Log.error("이미지 업로드 실패: \(error)")
                }
            }
        }
    }

    /// 촬영한 이미지를 이용해서 서버에 작품 매칭 요청
    func matchArtwork(
        imageData: Data,
        threshold: Double
    ) {
        let base64String = imageData.base64EncodedString()
        let request = ArtworkMatchRequestDto(
            imageBase64: base64String,
            threshold: threshold
        )

        isMatching = true
        errorMessage = nil
        matchResponse = nil
        topCandidate = nil
        matchedArtworkImage = nil
        showFailAlert = false

        artworkService.matchArtwork(request: request) { [weak self] result in
            guard let self = self else { return }

            Task { @MainActor in
                switch result {
                case .success(let response):
                    self.matchResponse = response

                    // topCandidate 선정
                    guard
                        let best = response.results.sorted(by: { $0.similarity > $1.similarity })
                            .first
                    else {
                        self.errorMessage = "일치하는 작품을 찾지 못했어요."
                        self.isMatching = false
                        self.showFailAlert = true
                        return
                    }

                    if let urlString = best.thumbnail_url,
                        let url = URL(string: urlString)
                    {
                        Task.detached { [weak self] in
                            guard let self else { return }
                            if let data = try? Data(contentsOf: url),
                                let uiImage = UIImage(data: data)
                            {
                                await MainActor.run {
                                    self.matchedArtworkImage = uiImage
                                    self.matchedArtistId = best.artist_id
                                    self.matchedArtworkId = best.artwork_id
                                    self.matchedExhibitions.append(contentsOf: best.exhibitions)
                                    self.isMatching = false
                                }
                            }
                        }
                    }

                    self.setArtworkInfo(artworkId: best.artwork_id, artistId: best.artist_id)
                    self.setExhivitionInfo(exhibitionId: best.exhibitions.first?.id ?? 0)

                case .failure(let error):
                    self.isMatching = false
                    self.showFailAlert = true
                    self.errorMessage = "작품 매칭 실패: \(error.localizedDescription)"
                    Log.error("작품 매칭 실패: \(error)")
                }
            }
        }
    }

    /// 인식된 작품의 작품명과 작가 정보를 저장하는 함수
    func setArtworkInfo(
        artworkId: Int,
        artistId: Int
    ) {
        // SwiftData에서 작품의 artistId 업데이트
        dataManager.updateArtworkArtist(artworkId: artworkId, artistId: artistId)

        Log.debug(
            "작품 정보 설정 - 작품ID: \(artworkId), 작가ID: \(artistId)"
        )
    }

    func setExhivitionInfo(exhibitionId: Int) {
        exhibitionService.getDetailExhibition(exhibitionId: exhibitionId) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.fetchExhibition(by: exhibitionId)
                    Log.debug("전시 상세 저장 완료. 작품 수: \(self.currentExhibition?.artworks.count ?? 0)")
                case .failure(let error):
                    Log.error("전시 상세 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 현재 전시 정보 가져오기
    func fetchExhibition(by id: Int) {
        let allExhibitions = dataManager.fetchAll(Exhibition.self)
        currentExhibition = allExhibitions.first { $0.id == id }
    }

    /// 전시를 \"나의 전시\"로 저장하고 아티스트와 연결
    func selectExhibitionAsUserExhibition() {
        guard let exhibition = currentExhibition else {
            Log.error("No exhibition to save.")
            return
        }

        exhibition.isUserSelected = true

        if let artistId = matchedArtistId {
            let allArtists = dataManager.fetchAll(Artist.self)
            if let currentArtist = allArtists.first(where: { $0.id == artistId }) {
                if !currentArtist.exhibitions.contains(exhibition.id) {
                    currentArtist.exhibitions.append(exhibition.id)
                }
            } else {
                Log.warning("Current artist (ID: \(artistId)) not found in SwiftData.")
            }

            for artwork in exhibition.artworks {
                if artwork.artistId != artistId {
                    artwork.artistId = artistId
                }
            }
        }

        Log.debug("Staged changes for exhibition '\(exhibition.title)'.")
        dataManager.saveContext()
    }

    /// 방문 기록 생성 API 함수
    func createVisitHistory(completion: @escaping (Bool) -> Void) {
        // UserDefaults에서 저장된 visitorUUID 가져오기
        guard
            let visitorUUID = UserDefaults.standard.string(
                forKey: UserDefaultsKey.visitorUUID.rawValue)
        else {
            Log.error("visitorUUID를 찾을 수 없습니다")
            completion(false)
            return
        }

        // SwiftData에서 UUID로 Visitor 조회
        let visitors = dataManager.fetchAll(Visitor.self)
        guard let visitor = visitors.first(where: { $0.uuid == visitorUUID }) else {
            Log.error("Visitor를 찾을 수 없습니다")
            completion(false)
            return
        }

        guard let exhibition = currentExhibition else {
            Log.error("No exhibition to save.")
            return
        }

        let request = MakeVisitHistoriesRequestDto(
            visitor_id: visitor.id,
            exhibition_id: exhibition.id
        )

        visitHistoriesService.makeVisitHistories(request: request) { result in
            switch result {
            case .success(let dto):
                Log.debug("방문 기록 생성 성공: visitId=\(dto.id)")
                UserDefaults.standard.set(dto.id, forKey: UserDefaultsKey.visitId.rawValue)
                completion(true)
            case .failure(let error):
                Log.error("방문 기록 생성 실패: \(error)")
                completion(false)
            }
        }
    }

    /// Artwork 상세 조회
    func fetchArtworkDetail(artworkId: Int, exhibitionId: Int) {
        artworkService.getArtworkDetail(artworkId: artworkId) { result in
            Task {
                switch result {
                case .success(let dto):
                    Log.debug("작품 상세 조회 성공! 작품명: \(dto.title)")
                    let artwork = ArtworkMapper.mapDtoToModel(dto, exhibitionId: exhibitionId)
                    self.artwork = artwork

                case .failure(let error):
                    Log.error("작품 상세 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Artist 상세 조회
    func fetchArtistDetail(artistId: Int) {
        artistService.getArtist(id: artistId) { result in
            Task {
                switch result {
                case .success(let dto):
                    Log.debug("작가 상세 조회 성공! 작가명: \(dto.name)")

                    let artist = ArtistMapper.toModel(from: dto)
                    self.artist = artist

                case .failure(let error):
                    Log.error("작가 상세 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}

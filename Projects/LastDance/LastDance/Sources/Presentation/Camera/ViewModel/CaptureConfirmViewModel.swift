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

    private let imageService: ImageAPIServiceProtocol
    private let artworkService: ArtworkAPIServiceProtocol

    init(
        imageService: ImageAPIServiceProtocol = ImageAPIService(),
        artworkService: ArtworkAPIServiceProtocol = ArtworkAPIService()
    ) {
        self.imageService = imageService
        self.artworkService = artworkService
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
        exhibitionIdFilter: Int?,
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

                    // 전시 ID로 필터링
                    let filtered: [ArtworkMatchResultDto]
                    if let exhibitionIdFilter {
                        let tmp = response.results.filter { item in
                            item.exhibitions.contains(where: { $0.id == exhibitionIdFilter })
                        }
                        filtered = tmp.isEmpty ? response.results : tmp
                    } else {
                        filtered = response.results
                    }

                    // topCandidate 선정 (가장 유사도가 높은 첫 번째)
                    guard let best = filtered.sorted(by: { $0.similarity > $1.similarity }).first
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
                                    self.isMatching = false
                                }
                            }
                        }
                    }

                case .failure(let error):
                    self.isMatching = false
                    self.showFailAlert = true
                    self.errorMessage = "작품 매칭 실패: \(error.localizedDescription)"
                    Log.error("작품 매칭 실패: \(error)")
                }
            }
        }
    }

}

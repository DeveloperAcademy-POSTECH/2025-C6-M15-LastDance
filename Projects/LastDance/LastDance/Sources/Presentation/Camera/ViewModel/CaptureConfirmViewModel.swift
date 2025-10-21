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
    @Published var uploadedImageUrl: String?
    @Published var errorMessage: String?

    private let imageService: ImageAPIServiceProtocol

    init(imageService: ImageAPIServiceProtocol = ImageAPIService()) {
        self.imageService = imageService
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
                    UserDefaults.standard.set(response.url, forKey: UserDefaultsKey.uploadedImageUrl.key)
                    Log.info("이미지 업로드 성공: \(response.url)")

                case .failure(let error):
                    self.errorMessage = "업로드 실패: \(error.localizedDescription)"
                    Log.error("이미지 업로드 실패: \(error)")
                }
            }
        }
    }
}

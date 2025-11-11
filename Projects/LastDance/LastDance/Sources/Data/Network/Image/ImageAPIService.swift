//
//  ImageAPIService.swift
//  LastDance
//
//  Created by 아우신얀 on 10/20/25.
//

import Foundation
import Moya

// MARK: - ImageAPIServiceProtocol
protocol ImageAPIServiceProtocol {
  func uploadImage(
    folder: ImageFolder,
    imageData: Data,
    completion: @escaping (Result<UploadImageResponseDto, Error>) -> Void
  )
}

// MARK: - ImageAPIService
final class ImageAPIService: ImageAPIServiceProtocol {
  private let provider: MoyaProvider<ImageAPI>

  init(provider: MoyaProvider<ImageAPI> = MoyaProvider<ImageAPI>(plugins: [NetworkLoggerPlugin()]))
  {
    self.provider = provider
  }

  /// 이미지 업로드 함수
  func uploadImage(
    folder: ImageFolder,
    imageData: Data,
    completion: @escaping (Result<UploadImageResponseDto, Error>) -> Void
  ) {
    provider.request(.uploadImage(folder: folder, imageData: imageData)) { result in
      switch result {
      case .success(let response):
        do {
          if let json = String(data: response.data, encoding: .utf8) {
            Log.debug("이미지 업로드 성공. 응답: \(json)")
          }
          let dto = try JSONDecoder().decode(UploadImageResponseDto.self, from: response.data)
          Log.info("이미지 업로드 완료. filename=\(dto.filename), url=\(dto.url)")
          completion(.success(dto))
        } catch {
          Log.error("디코딩 실패: \(error)")
          completion(.failure(NetworkError.decodingFailed))
        }
      case .failure(let error):
        if let data = error.response?.data,
          let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
        {
          let messages = err.detail.map { $0.msg }.joined(separator: ", ")
          Log.warning("Validation Error: \(messages)")
        }
        Log.error("이미지 업로드 실패: \(error.localizedDescription)")
        completion(.failure(error))
      }
    }
  }
}

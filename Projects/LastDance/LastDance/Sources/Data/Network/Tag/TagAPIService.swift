//
//  TagAPIService.swift
//  LastDance
//
//  Created by 배현진 on 10/19/25.
//

import Foundation
import Moya

protocol TagAPIServiceProtocol {
  func getTags(
    categoryId: Int?,
    completion: @escaping (Result<[TagDetailResponseDto], Error>) -> Void)
  func getTag(
    id: Int,
    completion: @escaping (Result<TagDetailResponseDto, Error>) -> Void)
}

final class TagAPIService: TagAPIServiceProtocol {
  private let provider: MoyaProvider<TagAPI>

  init(provider: MoyaProvider<TagAPI> = MoyaProvider<TagAPI>(plugins: [NetworkLoggerPlugin()])) {
    self.provider = provider
  }

  func getTags(
    categoryId: Int?,
    completion: @escaping (Result<[TagDetailResponseDto], Error>) -> Void
  ) {
    provider.request(.getTags(categoryId: categoryId)) { result in
      switch result {
      case .success(let response):
        do {
          if let json = String(data: response.data, encoding: .utf8) {
            Log.debug("성공. 응답: \(json)")
          }
          let list = try JSONDecoder().decode(
            [TagDetailResponseDto].self,
            from: response.data)
          completion(.success(list))
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
        Log.error("API 실패: \(error.localizedDescription)")
        completion(.failure(error))
      }
    }
  }

  func getTag(
    id: Int,
    completion: @escaping (Result<TagDetailResponseDto, Error>) -> Void
  ) {
    provider.request(.getTag(id: id)) { result in
      switch result {
      case .success(let response):
        do {
          if let json = String(data: response.data, encoding: .utf8) {
            Log.debug("성공. 응답: \(json)")
          }
          let dto = try JSONDecoder().decode(
            TagDetailResponseDto.self,
            from: response.data)
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
        Log.error("API 실패: \(error.localizedDescription)")
        completion(.failure(error))
      }
    }
  }
}

// TODO: - 머지 이후 Mapper 폴더로 이동 필요
enum TagMapper {
  static func toTag(_ dto: TagDetailResponseDto) -> Tag {
    Tag(
      id: dto.id,
      name: dto.name,
      categoryId: dto.category_id
    )
  }
}

//
//  TagCategoryAPIService.swift
//  LastDance
//
//  Created by 배현진 on 10/19/25.
//

import Foundation
import Moya

protocol TagCategoryAPIServiceProtocol {
  func getTagCategories(
    completion: @escaping (Result<[TagCategoryListResponseDto], Error>) -> Void)
  func getTagCategory(
    id: Int,
    completion: @escaping (Result<TagCategoryDetailResponseDto, Error>) -> Void)
}

final class TagCategoryAPIService: TagCategoryAPIServiceProtocol {
  private let provider: MoyaProvider<TagCategoryAPI>

  init(
    provider: MoyaProvider<TagCategoryAPI> = MoyaProvider<TagCategoryAPI>(plugins: [
      NetworkLoggerPlugin()
    ])
  ) {
    self.provider = provider
  }

  func getTagCategories(
    completion: @escaping (Result<[TagCategoryListResponseDto], Error>) -> Void
  ) {
    provider.request(.getTagCategories) { result in
      switch result {
      case .success(let response):
        do {
          if let json = String(data: response.data, encoding: .utf8) {
            Log.debug("[TagCategoryAPI] 목록 응답: \(json)")
          }
          let list = try JSONDecoder().decode(
            [TagCategoryListResponseDto].self, from: response.data)
          completion(.success(list))
        } catch {
          Log.error("[TagCategoryAPI] 디코딩 실패: \(error)")
          completion(.failure(NetworkError.decodingFailed))
        }
      case .failure(let error):
        if let data = error.response?.data,
          let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
        {
          let messages = err.detail.map { $0.msg }.joined(separator: ", ")
          Log.warning("[TagCategoryAPI] Validation Error: \(messages)")
        }
        Log.error("[TagCategoryAPI] API 실패: \(error.localizedDescription)")
        completion(.failure(error))
      }
    }
  }

  func getTagCategory(
    id: Int, completion: @escaping (Result<TagCategoryDetailResponseDto, Error>) -> Void
  ) {
    provider.request(.getTagCategory(id: id)) { result in
      switch result {
      case .success(let response):
        do {
          if let json = String(data: response.data, encoding: .utf8) {
            Log.debug("[TagCategoryAPI] 상세 응답(\(id)): \(json)")
          }
          let dto = try JSONDecoder().decode(TagCategoryDetailResponseDto.self, from: response.data)
          completion(.success(dto))
        } catch {
          Log.error("[TagCategoryAPI] 디코딩 실패: \(error)")
          completion(.failure(NetworkError.decodingFailed))
        }
      case .failure(let error):
        if let data = error.response?.data,
          let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
        {
          let messages = err.detail.map { $0.msg }.joined(separator: ", ")
          Log.warning("[TagCategoryAPI] Validation Error: \(messages)")
        }
        Log.error("[TagCategoryAPI] API 실패: \(error.localizedDescription)")
        completion(.failure(error))
      }
    }
  }
}

// TODO: - 머지 이후 Mapper 폴더로 이동 필요
enum TagCategoryMapper {
  static func toCategory(
    from dto: TagCategoryListResponseDto,
    tags: [Tag]
  ) -> TagCategory {
    TagCategory(
      id: dto.id,
      name: dto.name,
      colorHex: dto.color_hex,
      tags: tags
    )
  }

  static func toCategory(from dto: TagCategoryDetailResponseDto) -> TagCategory {
    let tags = dto.tags.map { TagMapper.toTag($0) }
    return TagCategory(
      id: dto.id,
      name: dto.name,
      colorHex: dto.color_hex,
      tags: tags
    )
  }
}

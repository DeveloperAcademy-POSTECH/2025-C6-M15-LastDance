//
//  ArtworkAPIService.swift
//  LastDance
//
//  Created by 아우신얀 on 10/18/25.
//

import Foundation
import Moya
import SwiftData

// MARK: ArtworkAPIServiceProtocol

protocol ArtworkAPIServiceProtocol {
    func getArtworks(
        artistId: Int?, exhibitionId: Int?,
        completion: @escaping (Result<[ArtworkDetailResponseDto], Error>) -> Void
    )
    func getArtworkDetail(
        artworkId: Int, completion: @escaping (Result<ArtworkDetailResponseDto, Error>) -> Void
    )
    func matchArtwork(
        request: ArtworkMatchRequestDto,
        completion: @escaping (Result<ArtworkMatchResponseDto, Error>) -> Void
    )
}

// MARK: ArtworkAPIService

final class ArtworkAPIService: ArtworkAPIServiceProtocol {
    private let provider: MoyaProvider<ArtworkAPI>

    init(provider: MoyaProvider<ArtworkAPI> = MoyaProvider<ArtworkAPI>()) {
        self.provider = provider
    }

    /// 작품 목록 조회하기 함수
    func getArtworks(
        artistId: Int?, exhibitionId: Int?,
        completion: @escaping (Result<[ArtworkDetailResponseDto], Error>) -> Void
    ) {
        Log.debug(
            "요청 파라미터 - artistId: \(String(describing: artistId)), exhibitionId: \(String(describing: exhibitionId))"
        )

        provider.request(.getArtworks(artistId: artistId, exhibitionId: exhibitionId)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("서버 응답: \(jsonString)")
                    }
                    let artworks = try JSONDecoder().decode(
                        [ArtworkDetailResponseDto].self, from: response.data
                    )

                    guard let exhibitionId else {
                        Log.error("exhibitionId 없음")
                        return
                    }
                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        for dto in artworks {
                            let artwork = ArtworkMapper.mapDtoToModel(
                                dto, exhibitionId: exhibitionId)
                            SwiftDataManager.shared.insert(artwork)
                        }
                        SwiftDataManager.shared.saveContext()  // 명시적으로 저장
                        Log.debug("로컬 저장 완료 - \(artworks.count)개 작품")
                    }

                    completion(.success(artworks))
                } catch {
                    Log.error("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                if let response = error.response,
                    let validationError = try? JSONDecoder().decode(
                        ErrorResponseDto.self, from: response.data
                    )
                {
                    let errorMessages = validationError.detail.map { $0.msg }.joined(
                        separator: ", ")
                    Log.warning("Validation Error: \(errorMessages)")
                }
                Log.error("API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 작품 상세 조회하기 함수
    func getArtworkDetail(
        artworkId: Int, completion: @escaping (Result<ArtworkDetailResponseDto, Error>) -> Void
    ) {
        Log.debug("작품 상세 조회 - artworkId: \(artworkId)")

        provider.request(.getArtworkDetail(artworkId: artworkId)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("작품 상세 조회 응답: \(jsonString)")
                    }

                    let dto = try JSONDecoder().decode(
                        ArtworkDetailResponseDto.self,
                        from: response.data
                    )

                    // 로컬 업데이트
                    DispatchQueue.main.async {
                        guard let container = SwiftDataManager.shared.container else { return }
                        let context = container.mainContext

                        do {
                            let descriptor = FetchDescriptor<Artwork>(
                                predicate: #Predicate<Artwork> { $0.id == dto.id }
                            )
                            if let existing = try context.fetch(descriptor).first {
                                // 디테일 정보만 업데이트, exhibitionId는 건드리지 않는다
                                existing.title = dto.title
                                existing.descriptionText = dto.description
                                existing.artistId = dto.artist_id
                                existing.thumbnailURL = dto.thumbnail_url

                                try context.save()
                                Log.debug("작품 상세 로컬 업데이트 완료 - id: \(dto.id)")
                            } else {
                                Log.warning("id=\(dto.id)인 Artwork가 로컬에 없음. insert는 하지 않음.")
                            }
                        } catch {
                            Log.error("실패: \(error)")
                        }
                    }

                    completion(.success(dto))
                } catch {
                    Log.error("작품 상세 조회 JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                if let response = error.response,
                    let validationError = try? JSONDecoder().decode(
                        ErrorResponseDto.self, from: response.data
                    )
                {
                    let errorMessages = validationError.detail.map { $0.msg }.joined(
                        separator: ", ")
                    Log.warning("Validation Error: \(errorMessages)")
                }
                Log.error("작품 상세 조회 API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    func matchArtwork(
        request: ArtworkMatchRequestDto,
        completion: @escaping (Result<ArtworkMatchResponseDto, Error>) -> Void
    ) {
        provider.request(.matchArtwork(dto: request)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("작품 매칭 응답: \(jsonString)")
                    }
                    let dto = try JSONDecoder().decode(
                        ArtworkMatchResponseDto.self,
                        from: response.data
                    )
                    completion(.success(dto))
                } catch {
                    Log.error("작품 매칭 JSON 디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case .failure(let error):
                if let data = error.response?.data,
                    let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                {
                    let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(messages)")
                }
                Log.error("작품 매칭 API 요청 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

//
//  ExhibitionAPIService.swift
//  LastDance
//
//  Created by 아우신얀 on 10/16/25.
//

import Foundation
import Moya
import SwiftData

// MARK: ExhibitionAPIService

protocol ExhibitionAPIServiceProtocol {
    func getExhibitions(
        status: String?, venueId: Int?,
        completion: @escaping (Result<[TotalExhibitionResponseDto], Error>) -> Void
    )
    func makeExhibition(
        dto: ExhibitionRequestDto,
        completion: @escaping (Result<ExhibitionResponseDto, Error>) -> Void
    )
    func getDetailExhibition(
        exhibitionId: Int, completion: @escaping (Result<ExhibitionResponseDto, Error>) -> Void
    )
    func getExhibitionDetailAsync(id: Int) async throws -> ExhibitionResponseDto
}

// MARK: ExhibitionAPIService

final class ExhibitionAPIService: ExhibitionAPIServiceProtocol {
    private let provider: MoyaProvider<ExhibitionAPI>

    init(provider: MoyaProvider<ExhibitionAPI> = MoyaProvider<ExhibitionAPI>()) {
        self.provider = provider
    }

    /// 전시 전체 조회 api
    func getExhibitions(
        status: String?,
        venueId: Int?,
        completion: @escaping (Result<[TotalExhibitionResponseDto], Error>) -> Void
    ) {
        // String을 ExhibitionStatus enum으로 변환
        let exhibitionStatus: ExhibitionStatus? = {
            guard let status = status else { return nil }
            return ExhibitionStatus(rawValue: status)
        }()

        provider.request(.getExhibitions(status: exhibitionStatus?.rawValue, venue_id: venueId)) {
            result in
            switch result {
            case .success(let response):
                do {
                    // 서버 응답 로깅
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("\(jsonString)")
                    }

                    // 배열로 직접 디코딩
                    let exhibitions = try JSONDecoder().decode(
                        [TotalExhibitionResponseDto].self, from: response.data
                    )

                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        for exhibitionDto in exhibitions {
                            let exhibition = exhibitionDto.toEntity()
                            SwiftDataManager.shared.upsertExhibition(exhibition)
                        }
                        Log.debug("로컬 저장 완료: \(exhibitions.count)개")
                    }

                    completion(.success(exhibitions))
                } catch {
                    Log.fault("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                Log.error("API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 전시 생성 api
    func makeExhibition(
        dto: ExhibitionRequestDto,
        completion: @escaping (Result<ExhibitionResponseDto, Error>) -> Void
    ) {
        provider.request(.makeExhibition(dto: dto)) { result in
            switch result {
            case .success(let response):
                do {
                    // 서버 응답 로깅
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("서버 응답: \(jsonString)")
                    }

                    let exhibition = try JSONDecoder().decode(
                        ExhibitionResponseDto.self, from: response.data)
                    Log.debug("전시 생성 성공: \(exhibition.title)")
                    completion(.success(exhibition))
                } catch {
                    Log.fault("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                Log.error("API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 전시 상세 조회 api
    func getDetailExhibition(
        exhibitionId: Int,
        completion: @escaping (Result<ExhibitionResponseDto, any Error>) -> Void
    ) {
        provider.request(.getDetailExhibition(exhibition_id: exhibitionId)) { result in
            switch result {
            case .success(let response):
                do {
                    // 서버 응답 로깅
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("서버 응답: \(jsonString)")
                    }

                    // 직접 디코딩
                    let exhibitionDto = try JSONDecoder().decode(
                        ExhibitionResponseDto.self, from: response.data
                    )
                    Log.debug("전시 상세 조회 성공: \(exhibitionDto.title)")

                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        let exhibition = exhibitionDto.toEntity()
                        SwiftDataManager.shared.upsertExhibition(exhibition)

                        // Artworks 독립적으로 저장
                        if let artworkInfos = exhibitionDto.artworks {
                            for artworkInfo in artworkInfos {
                                let artwork = Artwork(
                                    id: artworkInfo.id,
                                    exhibitionId: exhibitionDto.id,
                                    title: artworkInfo.title,
                                    descriptionText: artworkInfo.description,
                                    artistId: artworkInfo.artist_id,
                                    thumbnailURL: artworkInfo.thumbnail_url,
                                    exhibition: exhibition
                                )
                                SwiftDataManager.shared.upsertArtwork(artwork)

                                if !exhibition.artworks.contains(where: { $0.id == artwork.id }) {
                                    exhibition.artworks.append(artwork)
                                }
                            }
                            Log.debug("저장 완료 (\(artworkInfos.count)개)")
                        }
                        SwiftDataManager.shared.saveContext()

                        completion(.success(exhibitionDto))
                    }
                } catch {
                    Log.fault("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                Log.error("API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
}

extension ExhibitionAPIService {
    func getExhibitionDetailAsync(id: Int) async throws -> ExhibitionResponseDto {
        try await withCheckedThrowingContinuation { continuation in
            self.getDetailExhibition(exhibitionId: id) { result in
                switch result {
                case .success(let dto):
                    continuation.resume(returning: dto)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

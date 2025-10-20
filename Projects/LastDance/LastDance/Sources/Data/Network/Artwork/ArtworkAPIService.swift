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
    func getArtworks(artistId: Int?, exhibitionId: Int?, completion: @escaping (Result<[ArtworkDetailResponseDto], Error>) -> Void)
    func getArtworkDetail(artworkId: Int, completion: @escaping (Result<ArtworkDetailResponseDto, Error>) -> Void)
    func makeArtwork(dto: MakeArtworkRequestDto, completion: @escaping (Result<ArtworkDetailResponseDto, Error>) -> Void)
}

// MARK: ArtworkAPIService
final class ArtworkAPIService: ArtworkAPIServiceProtocol {
    private let provider: MoyaProvider<ArtworkAPI>

    init(provider: MoyaProvider<ArtworkAPI> = MoyaProvider<ArtworkAPI>()) {
        self.provider = provider
    }

    /// 작품 목록 조회하기 함수
    func getArtworks(artistId: Int?, exhibitionId: Int?, completion: @escaping (Result<[ArtworkDetailResponseDto], Error>) -> Void) {
        Log.debug("요청 파라미터 - artistId: \(String(describing: artistId)), exhibitionId: \(String(describing: exhibitionId))")

        provider.request(.getArtworks(artistId: artistId, exhibitionId: exhibitionId)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("서버 응답: \(jsonString)")
                    }
                    let artworks = try JSONDecoder().decode([ArtworkDetailResponseDto].self, from: response.data)

                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        artworks.forEach { dto in
                            let artwork = ArtworkMapper.mapDtoToModel(dto, exhibitionId: exhibitionId)
                            SwiftDataManager.shared.insert(artwork)
                        }
                        Log.debug("로컬 저장 완료 - \(artworks.count)개 작품")
                    }

                    completion(.success(artworks))
                } catch {
                    Log.error("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                if let response = error.response,
                   let validationError = try? JSONDecoder().decode(ErrorResponseDto.self, from: response.data) {
                    let errorMessages = validationError.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(errorMessages)")
                }
                Log.error("API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 작품 상세 조회하기 함수
    func getArtworkDetail(artworkId: Int, completion: @escaping (Result<ArtworkDetailResponseDto, Error>) -> Void) {
        Log.debug("작품 상세 조회 - artworkId: \(artworkId)")

        provider.request(.getArtworkDetail(artworkId: artworkId)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("작품 상세 조회 응답: \(jsonString)")
                    }
                    let artwork = try JSONDecoder().decode(ArtworkDetailResponseDto.self, from: response.data)

                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        let artworkModel = ArtworkMapper.mapDtoToModel(artwork, exhibitionId: nil)
                        SwiftDataManager.shared.insert(artworkModel)
                        Log.debug("작품 상세 로컬 저장 완료")
                    }

                    completion(.success(artwork))
                } catch {
                    Log.error("작품 상세 조회 JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                if let response = error.response,
                   let validationError = try? JSONDecoder().decode(ErrorResponseDto.self, from: response.data) {
                    let errorMessages = validationError.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(errorMessages)")
                }
                Log.error("작품 상세 조회 API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 작품 생성하기 함수
    func makeArtwork(dto: MakeArtworkRequestDto, completion: @escaping (Result<ArtworkDetailResponseDto, Error>) -> Void) {
        Log.debug("작품 생성 - title: \(dto.title), artistId: \(dto.artist_id)")

        provider.request(.makeArtwork(dto: dto)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("작품 생성 응답: \(jsonString)")
                    }
                    let artwork = try JSONDecoder().decode(ArtworkDetailResponseDto.self, from: response.data)

                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        let artworkModel = ArtworkMapper.mapDtoToModel(artwork, exhibitionId: nil)
                        SwiftDataManager.shared.insert(artworkModel)
                        Log.debug("작품 생성 로컬 저장 완료")
                    }

                    completion(.success(artwork))
                } catch {
                    Log.error("작품 생성 JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                if let response = error.response,
                   let validationError = try? JSONDecoder().decode(ErrorResponseDto.self, from: response.data) {
                    let errorMessages = validationError.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(errorMessages)")
                }
                Log.error("작품 생성 API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
}

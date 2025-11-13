//
//  ArtistAPIService.swift
//  LastDance
//
//  Created by 배현진 on 10/18/25.
//

import Foundation
import Moya

// MARK: - ArtistAPIServiceProtocol

protocol ArtistAPIServiceProtocol {
    func getArtists(
        completion:
            @escaping (Result<[ArtistListItemDto], Error>)
            -> Void
    )
    func createArtist(
        request: ArtistCreateRequestDto,
        completion:
            @escaping (Result<ArtistDetailResponseDto, Error>)
            -> Void
    )
    func getArtist(
        id: Int,
        completion:
            @escaping (Result<ArtistDetailResponseDto, Error>)
            -> Void
    )
    func getArtistByUUID(
        _ uuid: String,
        completion:
            @escaping (Result<ArtistDetailResponseDto, Error>)
            -> Void
    )
}

// MARK: - ArtistAPIService

final class ArtistAPIService: ArtistAPIServiceProtocol {
    private let provider: MoyaProvider<ArtistAPI>

    init(
        provider: MoyaProvider<ArtistAPI> = MoyaProvider<ArtistAPI>(plugins: [NetworkLoggerPlugin()]
        )
    ) {
        self.provider = provider
    }

    /// Artist 전체 목록 가져오기 함수
    func getArtists(
        completion:
            @escaping (Result<[ArtistListItemDto], Error>)
            -> Void
    ) {
        provider.request(.getArtists) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("API 요청 성공. 응답: \(json)")
                    }
                    let list = try JSONDecoder().decode(
                        [ArtistListItemDto].self, from: response.data)

                    DispatchQueue.main.async {
                        for dto in list {
                            let model = ArtistMapper.toModel(from: dto)
                            SwiftDataManager.shared.upsertArtist(model)
                        }
                    }
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
                Log.error("API 요청 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    /// Artist 정보 생성 함수
    func createArtist(
        request: ArtistCreateRequestDto,
        completion:
            @escaping (Result<ArtistDetailResponseDto, Error>)
            -> Void
    ) {
        provider.request(.createArtist(dto: request)) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("API 요청 성공. 응답: \(json)")
                    }
                    let dto = try JSONDecoder().decode(
                        ArtistDetailResponseDto.self, from: response.data)
                    Log.info("Artist created. id=\(dto.id), uuid=\(dto.uuid)")
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
                Log.error("API 요청 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    /// id 정보로 특정 Artist 가져오기 함수
    func getArtist(
        id: Int,
        completion:
            @escaping (Result<ArtistDetailResponseDto, Error>)
            -> Void
    ) {
        provider.request(.getArtist(id: id)) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("API 요청 성공. 응답: \(json)")
                    }
                    let dto = try JSONDecoder().decode(
                        ArtistDetailResponseDto.self, from: response.data)

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
                Log.error("API 요청 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    /// UUID 정보로 특정 Artist 정보 가져오기
    func getArtistByUUID(
        _ uuid: String,
        completion:
            @escaping (Result<ArtistDetailResponseDto, Error>)
            -> Void
    ) {
        provider.request(.getArtistByUUID(uuid: uuid)) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("API 요청 성공. 응답: \(json)")
                    }
                    let dto = try JSONDecoder().decode(
                        ArtistDetailResponseDto.self, from: response.data)
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
                Log.error("API 요청 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

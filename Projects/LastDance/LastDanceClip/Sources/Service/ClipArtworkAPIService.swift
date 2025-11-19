//
//  ClipArtworkAPIService.swift
//  LastDance
//
//  Created by 배현진 on 11/10/25.
//

import Foundation
import Moya

protocol ClipArtworkAPIServiceProtocol {
    func loadArtworkDetail(id: Int) async throws -> Artwork
    func loadArtistDetail(id: Int) async throws -> Artist
}

final class ClipArtworkAPIService: ClipArtworkAPIServiceProtocol {
    private let provider = MoyaProvider<ArtworkAPI>()
    private let artistProvider = MoyaProvider<ArtistAPI>()
    
    func loadArtworkDetail(id: Int) async throws -> Artwork {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getArtworkDetail(artworkId: id)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try JSONDecoder().decode(
                            ArtworkDetailResponseDto.self,
                            from: response.data)
                        let artwork = ArtworkMapper.mapDtoToModel(dto, exhibitionId: nil)
                        continuation.resume(returning: artwork)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func loadArtistDetail(id: Int) async throws -> Artist {
        return try await withCheckedThrowingContinuation { continuation in
            artistProvider.request(.getArtist(id: id)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try JSONDecoder().decode(
                            ArtistListItemDto.self,
                            from: response.data)
                        let artist = ArtistMapper.toModel(from: dto)
                        continuation.resume(returning: artist)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

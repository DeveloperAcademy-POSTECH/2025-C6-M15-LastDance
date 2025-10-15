//
//  ReactionAPIService.swift
//  LastDance
//
//  Created by 아우신얀 on 10/16/25.
//

import Foundation
import Moya

protocol ReactionAPIServiceProtocol {
    func createReaction(dto: ReactionRequestDto, completion: @escaping (Result<ReactionResponseDto, Error>) -> Void)
}

final class ReactionAPIService: ReactionAPIServiceProtocol {
    private let provider: MoyaProvider<ReactionAPI>

    init(provider: MoyaProvider<ReactionAPI> = MoyaProvider<ReactionAPI>()) {
        self.provider = provider
    }

    func createReaction(dto: ReactionRequestDto, completion: @escaping (Result<ReactionResponseDto, Error>) -> Void) {
        provider.request(.createReaction(dto: dto)) { result in
            switch result {
            case .success(let response):
                do {
                    let responseDto = try JSONDecoder().decode(ReactionResponseDto.self, from: response.data)
                    completion(.success(responseDto))
                } catch {
                    Log.debug("[ReactionAPIService] JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                Log.debug("[ReactionAPIService] API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
}

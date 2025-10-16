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
    func getReactions(artworkId: Int?, visitorId: Int?, visitId: Int?, completion: @escaping (Result<[GetReactionResponseDto], Error>) -> Void)
}

final class ReactionAPIService: ReactionAPIServiceProtocol {
    private let provider: MoyaProvider<ReactionAPI>

    init(provider: MoyaProvider<ReactionAPI> = MoyaProvider<ReactionAPI>()) {
        self.provider = provider
    }

    /// 반응 전송하기 함수
    func createReaction(dto: ReactionRequestDto, completion: @escaping (Result<ReactionResponseDto, Error>) -> Void) {
        provider.request(.createReaction(dto: dto)) { result in
            switch result {
            case .success(let response):
                do {
                    // 서버 응답 JSON 로깅
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("[ReactionAPIService] 서버 응답: \(jsonString)")
                    }
                    let reactionDetail = try JSONDecoder().decode(ReactionDetail.self, from: response.data)
                    let responseDto = ReactionResponseDto(code: response.statusCode, data: reactionDetail)
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

    /// 전체 반응 조회하기 함수
    func getReactions(artworkId: Int?, visitorId: Int?, visitId: Int?, completion: @escaping (Result<[GetReactionResponseDto], Error>) -> Void) {
        Log.debug("[ReactionAPIService] 요청 파라미터 - artworkId: \(String(describing: artworkId)), visitorId: \(String(describing: visitorId)), visitId: \(String(describing: visitId))")

        provider.request(.getReactions(artworkId: artworkId, visitorId: visitorId, visitId: visitId)) { result in
            switch result {
            case .success(let response):
                do {
                    // 서버 응답 JSON 로깅
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("[ReactionAPIService] 전체 조회 응답: \(jsonString)")
                    }
                    let reactions = try JSONDecoder().decode([GetReactionResponseDto].self, from: response.data)
                    completion(.success(reactions))
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

//
//  ReactionAPIService.swift
//  LastDance
//
//  Created by 신얀 on 10/16/25.
//

import Foundation
import Moya
import SwiftData

// MARK: ReactionAPIServiceProtocol
protocol ReactionAPIServiceProtocol {
    func createReaction(dto: ReactionRequestDto, completion: @escaping (Result<ReactionResponseDto, Error>) -> Void)
    func getReactions(artworkId: Int?, visitorId: Int?, visitId: Int?, completion: @escaping (Result<[GetReactionResponseDto], Error>) -> Void)
    func getDetailReaction(reactionId: Int, completion: @escaping (Result<ReactionResponseDto, Error>) -> Void)
}

// MARK: ReactionAPIService
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
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("서버 응답: \(jsonString)")
                    }
                    let reactionDetail = try JSONDecoder().decode(ReactionDetailResponseDto.self, from: response.data)
                    let responseDto = ReactionResponseDto(code: response.statusCode, data: reactionDetail)

                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        let reaction = self.mapDtoToModel(reactionDetail)
                        SwiftDataManager.shared.insert(reaction)
                        Log.debug("로컬 저장 완료")
                    }
                    completion(.success(responseDto))
                } catch {
                    Log.error("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                // ValidationError 처리
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

    /// 전체 반응 조회하기 함수
    func getReactions(artworkId: Int?,
                      visitorId: Int?,
                      visitId: Int?,
                      completion: @escaping (Result<[GetReactionResponseDto], Error>) -> Void) {
        Log.debug("요청 파라미터 - artworkId: \(String(describing: artworkId)), visitorId: \(String(describing: visitorId)), visitId: \(String(describing: visitId))")

        provider.request(.getReactions(artworkId: artworkId, visitorId: visitorId, visitId: visitId)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("전체 조회 응답: \(jsonString)")
                    }
                    let reactions = try JSONDecoder().decode([GetReactionResponseDto].self, from: response.data)
                    completion(.success(reactions))
                } catch {
                    Log.error("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                // ValidationError 처리
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
    
    /// 반응 상세 조회하기 함수
    func getDetailReaction(reactionId: Int, completion: @escaping (Result<ReactionResponseDto, Error>) -> Void) {
        Log.debug("요청 파라미터 - reactionId: \(String(describing: reactionId))")

        provider.request(.getDetailReaction(reactionId: reactionId)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("상세 조회 응답: \(jsonString)")
                    }
                    let reactionDetail = try JSONDecoder().decode(ReactionDetailResponseDto.self, from: response.data)
                    let responseDto = ReactionResponseDto(code: response.statusCode, data: reactionDetail)

                    DispatchQueue.main.async {
                        let reaction = self.mapDtoToModel(reactionDetail)
                        SwiftDataManager.shared.insert(reaction)
                        Log.debug("로컬 저장 완료")
                    }

                    completion(.success(responseDto))
                } catch {
                    Log.error("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                // ValidationError 처리
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

    // MARK: - Mapper
    /// ReactionDetail DTO를 Reaction Model로 변환
    private func mapDtoToModel(_ dto: ReactionDetailResponseDto) -> Reaction {
        // tags를 category 문자열 배열로 변환
        let categories = dto.tags.map { $0.name }

        // created_at 문자열을 Date로 변환
        let dateFormatter = ISO8601DateFormatter()
        let createdAt = dateFormatter.date(from: dto.created_at) ?? Date()

        return Reaction(
            id: String(dto.id),
            artworkId: dto.artwork_id,
            visitorId: dto.visitor_id,
            category: categories,
            comment: dto.comment,
            createdAt: createdAt
        )
    }
}

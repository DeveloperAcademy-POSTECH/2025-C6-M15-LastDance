//
//  ClipReactionAPIService.swift
//  LastDance
//
//  Created by 배현진 on 11/10/25.
//

import Foundation
import Moya

/// App Clip에서만 쓸, 로컬 저장 안 하는 버전
// MARK: - Protocol
protocol ClipReactionAPIServiceProtocol {
    func createReaction(dto: ReactionRequestDto) async throws
}

// MARK: - Service
final class ClipReactionAPIService: ClipReactionAPIServiceProtocol {
    private let provider: MoyaProvider<ReactionAPI>

    init(provider: MoyaProvider<ReactionAPI> = MoyaProvider<ReactionAPI>()) {
        self.provider = provider
    }

    func createReaction(dto: ReactionRequestDto) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            provider.request(.createReaction(dto: dto)) { result in
                switch result {
                case .success(let response):
                    guard (200..<300).contains(response.statusCode) else {
                        continuation.resume(throwing: URLError(.badServerResponse))
                        return
                    }

                    // 디버그 로그만
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("서버 응답(AppClip): \(jsonString)")
                    }

                    continuation.resume(returning: ())
                case .failure(let error):
                    // 🔥 실패 시 여기에 URL 찍기
                            if let request = error.response?.request {
                                Log.error("❌ [FAIL] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
                            } else {
                                Log.error("❌ No request info in error.response")
                            }

                            // 🔥 상태 코드/본문까지 찍기
                            if let response = error.response,
                               let json = String(data: response.data, encoding: .utf8) {
                                Log.error("Status: \(response.statusCode) | Body: \(json)")
                            }

                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

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
    func getExhibitions(status: String?, venueId: Int?, completion: @escaping (Result<[ExhibitionResponseDto], Error>) -> Void)
}

// MARK: ExhibitionAPIService
final class ExhibitionAPIService: ExhibitionAPIServiceProtocol {
    private let provider: MoyaProvider<ExhibitionAPI>

    init(provider: MoyaProvider<ExhibitionAPI> = MoyaProvider<ExhibitionAPI>()) {
        self.provider = provider
    }

    /// 전시 전체 조회
    func getExhibitions(status: String?, venueId: Int?, completion: @escaping (Result<[ExhibitionResponseDto], Error>) -> Void) {
        // String을 ExhibitionStatus enum으로 변환
        let exhibitionStatus: ExhibitionStatus? = {
            guard let status = status else { return nil }
            return ExhibitionStatus(rawValue: status)
        }()

        provider.request(.getExhibitions(status: exhibitionStatus?.rawValue, venue_id: venueId)) { result in
            switch result {
            case .success(let response):
                do {
                    // 서버 응답 로깅
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("[ExhibitionAPIService] 서버 응답: \(jsonString)")
                    }

                    let baseResponse = try JSONDecoder().decode(BaseResponse<[ExhibitionResponseDto]>.self, from: response.data)

                    if let exhibitions = baseResponse.data {
                        // DTO를 Model로 변환하여 로컬에 저장
                        DispatchQueue.main.async {
                            for exhibitionDto in exhibitions {
                                let exhibition = exhibitionDto.toEntity()
                                SwiftDataManager.shared.insert(exhibition)
                            }
                            Log.debug("[ExhibitionAPIService] 로컬 저장 완료: \(exhibitions.count)개")
                        }

                        completion(.success(exhibitions))
                    } else {
                        completion(.success([]))
                    }
                } catch {
                    Log.debug("[ExhibitionAPIService] JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                Log.debug("[ExhibitionAPIService] API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
}

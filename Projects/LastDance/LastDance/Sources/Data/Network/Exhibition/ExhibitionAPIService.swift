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
    func makeExhibition(dto: ExhibitionRequestDto, completion: @escaping (Result<MakeExhibitionResponseDto, Error>) -> Void)
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

                    // 배열로 직접 디코딩
                    let exhibitions = try JSONDecoder().decode([ExhibitionResponseDto].self, from: response.data)

                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        for exhibitionDto in exhibitions {
                            let exhibition = exhibitionDto.toEntity()
                            SwiftDataManager.shared.insert(exhibition)
                        }
                        Log.debug("[ExhibitionAPIService] 로컬 저장 완료: \(exhibitions.count)개")
                    }

                    completion(.success(exhibitions))
                } catch {
                    Log.fault("[ExhibitionAPIService] JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                Log.error("[ExhibitionAPIService] API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 전시 작품 등록
    func makeExhibition(dto: ExhibitionRequestDto, completion: @escaping (Result<MakeExhibitionResponseDto, Error>) -> Void) {
        provider.request(.makeExhibition(dto: dto)) { result in
            switch result {
            case .success(let response):
                do {
                    // 서버 응답 로깅
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("[ExhibitionAPIService] makeExhibition 서버 응답: \(jsonString)")
                    }

                    // 성공 응답 시도
                    let baseResponse = try JSONDecoder().decode(BaseResponse<MakeExhibitionResponseDto>.self, from: response.data)

                    if let exhibitionData = baseResponse.data {
                        Log.debug("[ExhibitionAPIService] 전시 작품 등록 성공: \(exhibitionData.title)")
                        completion(.success(exhibitionData))
                    } else {
                        let error = NSError(domain: "ExhibitionAPIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "응답 데이터가 없습니다."])
                        completion(.failure(error))
                    }
                } catch {
                    // 실패 응답 파싱 시도
                    do {
                        let errorResponse = try JSONDecoder().decode(ErrorResponseDto.self, from: response.data)
                        Log.error("[ExhibitionAPIService] makeExhibition 실패: \(errorResponse.detail.map { $0.msg }.joined(separator: ", "))")
                        completion(.failure(errorResponse))
                    } catch {
                        Log.fault("[ExhibitionAPIService] makeExhibition JSON 디코딩 실패: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                Log.error("[ExhibitionAPIService] makeExhibition API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
}

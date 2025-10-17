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
    func getExhibitions(status: String?, venueId: Int?, completion: @escaping (Result<[TotalExhibitionResponseDto], Error>) -> Void)
    func makeExhibition(dto: ExhibitionRequestDto, completion: @escaping (Result<ExhibitionResponseDto, Error>) -> Void)
    func getDetailExhibition(exhibitionId: Int, completion: @escaping (Result<ExhibitionResponseDto, Error>) -> Void)
}

// MARK: ExhibitionAPIService
final class ExhibitionAPIService: ExhibitionAPIServiceProtocol {
    private let provider: MoyaProvider<ExhibitionAPI>

    init(provider: MoyaProvider<ExhibitionAPI> = MoyaProvider<ExhibitionAPI>()) {
        self.provider = provider
    }

    /// 전시 전체 조회 api
    func getExhibitions(status: String?, venueId: Int?, completion: @escaping (Result<[TotalExhibitionResponseDto], Error>) -> Void) {
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
                    let exhibitions = try JSONDecoder().decode([TotalExhibitionResponseDto].self, from: response.data)

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

    /// 전시 생성 api
    func makeExhibition(dto: ExhibitionRequestDto,
                        completion: @escaping (Result<ExhibitionResponseDto, Error>) -> Void) {
        provider.request(.makeExhibition(dto: dto)) { result in
            switch result {
            case .success(let response):
                do {
                    // 서버 응답 로깅
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("[ExhibitionAPIService] makeExhibition 서버 응답: \(jsonString)")
                    }

                    let exhibition = try JSONDecoder().decode(ExhibitionResponseDto.self, from: response.data)
                    Log.debug("[ExhibitionAPIService] 전시 생성 성공: \(exhibition.title)")
                    completion(.success(exhibition))
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
    
    /// 전시 상세 조회 api
    func getDetailExhibition(exhibitionId: Int, completion: @escaping (Result<ExhibitionResponseDto, any Error>) -> Void) {
        provider.request(.getDetailExhibition(exhibition_id: exhibitionId)) { result in
            switch result {
            case .success(let response):
                do {
                    // 서버 응답 로깅
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("[ExhibitionAPIService] getDetailExhibition 서버 응답: \(jsonString)")
                    }

                    // 직접 디코딩
                    let exhibitionDto = try JSONDecoder().decode(ExhibitionResponseDto.self, from: response.data)
                    Log.debug("[ExhibitionAPIService] 전시 상세 조회 성공: \(exhibitionDto.title)")

                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        let exhibition = exhibitionDto.toEntity()
                        SwiftDataManager.shared.insert(exhibition)
                        Log.debug("[ExhibitionAPIService] 전시 상세 로컬 저장 완료")
                    }

                    completion(.success(exhibitionDto))
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
}

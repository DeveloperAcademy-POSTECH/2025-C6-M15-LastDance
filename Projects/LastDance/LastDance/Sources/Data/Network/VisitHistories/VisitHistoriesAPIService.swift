//
//  VisitHistoriesAPIService.swift
//  LastDance
//
//  Created by 아우신얀 on 10/20/25.
//

import Foundation
import Moya
import SwiftData

// MARK: VisitHistoriesAPIServiceProtocol

protocol VisitHistoriesAPIServiceProtocol {
    func makeVisitHistories(
        request: MakeVisitHistoriesRequestDto,
        completion: @escaping (Result<VisitorHistoriesResponseDto, Error>) -> Void
    )
    func getVisitHistories(
        visitorId: Int,
        exhibitionId: Int,
        completion: @escaping (Result<[VisitorHistoriesResponseDto], Error>) -> Void
    )
    func getVisitHistory(
        visitId: Int,
        completion: @escaping (Result<VisitorHistoriesResponseDto, Error>) -> Void
    )
}

// MARK: VisitHistoriesAPIService

final class VisitHistoriesAPIService: VisitHistoriesAPIServiceProtocol {
    private let provider: MoyaProvider<VisitHistoriesAPI>

    init(
        provider: MoyaProvider<VisitHistoriesAPI> = MoyaProvider<VisitHistoriesAPI>(plugins: [
            NetworkLoggerPlugin(),
        ])
    ) {
        self.provider = provider
    }

    /// 방문 기록 생성 함수
    func makeVisitHistories(
        request: MakeVisitHistoriesRequestDto,
        completion: @escaping (Result<VisitorHistoriesResponseDto, Error>) -> Void
    ) {
        provider.request(.makeVisitHistories(dto: request)) { result in
            switch result {
            case let .success(response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("makeVisitHistories 응답: \(json)")
                    }
                    let dto = try JSONDecoder().decode(
                        VisitorHistoriesResponseDto.self,
                        from: response.data
                    )

                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        if let visitHistory = VisitHistoryMapper.toModel(from: dto) {
                            SwiftDataManager.shared.insert(visitHistory)
                            Log.debug("방문 기록 로컬 저장 완료: id=\(visitHistory.id)")
                        }
                        completion(.success(dto))
                    }

                } catch {
                    Log.error("디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case let .failure(error):
                if let data = error.response?.data,
                   let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                {
                    let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(messages)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 방문 기록 목록 조회 함수
    func getVisitHistories(
        visitorId: Int,
        exhibitionId: Int,
        completion: @escaping (Result<[VisitorHistoriesResponseDto], Error>) -> Void
    ) {
        provider.request(.getVisitHistories(visitorId: visitorId, exhibitionId: exhibitionId)) {
            result in
            switch result {
            case let .success(response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("getVisitHistories 응답: \(json)")
                    }
                    let items = try JSONDecoder().decode(
                        [VisitorHistoriesResponseDto].self,
                        from: response.data
                    )

                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        for dto in items {
                            if let visitHistory = VisitHistoryMapper.toModel(from: dto) {
                                SwiftDataManager.shared.insert(visitHistory)
                            }
                        }
                        Log.debug("방문 기록 로컬 저장 완료: \(items.count)개")
                    }

                    completion(.success(items))
                } catch {
                    Log.error("디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case let .failure(error):
                if let data = error.response?.data,
                   let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                {
                    let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(messages)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 특정 방문 기록 조회 함수
    func getVisitHistory(
        visitId: Int,
        completion: @escaping (Result<VisitorHistoriesResponseDto, Error>) -> Void
    ) {
        provider.request(.getVisitHistory(visitId: visitId)) { result in
            switch result {
            case let .success(response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("getVisitHistory 응답: \(json)")
                    }
                    let dto = try JSONDecoder().decode(
                        VisitorHistoriesResponseDto.self,
                        from: response.data
                    )

                    // DTO를 Model로 변환하여 로컬에 저장
                    DispatchQueue.main.async {
                        if let visitHistory = VisitHistoryMapper.toModel(from: dto) {
                            SwiftDataManager.shared.insert(visitHistory)
                            Log.debug("방문 기록 로컬 저장 완료: id=\(visitHistory.id)")
                        }
                    }

                    completion(.success(dto))
                } catch {
                    Log.error("디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case let .failure(error):
                if let data = error.response?.data,
                   let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                {
                    let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(messages)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
}

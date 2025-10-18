//
//  VisitorAPIService.swift
//  LastDance
//
//  Created by 배현진 on 10/17/25.
//

import Foundation
import Moya

// MARK: VisitorAPIServiceProtocol
protocol VisitorAPIServiceProtocol {
    func getVisitors(
        completion: @escaping (Result<[VisitorListResponseDto], Error>)
        -> Void
    )
    func createVisitor(
        request: VisitorCreateRequestDto,
        completion: @escaping (Result<VisitorDetailResponseDto, Error>)
        -> Void
    )
    func getVisitor(
        id: Int,
        completion: @escaping (Result<VisitorDetailResponseDto, Error>)
        -> Void
    )
    func getVisitorByUUID(
        _ uuid: String,
        completion: @escaping (Result<VisitorDetailResponseDto, Error>)
        -> Void
    )
}

// MARK: VisitorAPIService
final class VisitorAPIService: VisitorAPIServiceProtocol {
    private let provider: MoyaProvider<VisitorAPI>

    init(provider: MoyaProvider<VisitorAPI> = MoyaProvider<VisitorAPI>(plugins: [NetworkLoggerPlugin()])) {
        self.provider = provider
    }

    /// Visitor 목록 가져오기 함수
    func getVisitors(
        completion: @escaping (Result<[VisitorListResponseDto], Error>)
        -> Void
    ) {
        provider.request(.getVisitors) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("getVisitors 응답: \(json)")
                    }
                    let items = try JSONDecoder().decode(
                        [VisitorListResponseDto].self,
                        from: response.data
                    )
                    
                    DispatchQueue.main.async {
                        items.forEach { dto in
                            let model = VisitorMapper.toModel(from: dto)
                            SwiftDataManager.shared.upsertVisitor(model)
                        }
                        // TODO: - 전체 Visitors 확인 용도 (이후에 제거 가능)
                        SwiftDataManager.shared.printAllVisitors()
                    }
                    
                    completion(.success(items))
                } catch {
                    Log.error("디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case .failure(let error):
                if let data = error.response?.data,
                   let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                    let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(messages)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// Visitor 정보 저장 함수
    func createVisitor(
        request: VisitorCreateRequestDto,
        completion: @escaping (Result<VisitorDetailResponseDto, Error>)
        -> Void
    ) {
        provider.request(.createVisitor(dto: request)) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("createVisitor 응답: \(json)")
                    }
                    let dto = try JSONDecoder().decode(
                        VisitorDetailResponseDto.self,
                        from: response.data
                    )
                    completion(.success(dto))
                } catch {
                    Log.error("디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case .failure(let error):
                if let data = error.response?.data,
                   let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                    let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(messages)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// id로 Visitor 정보 가져오기 함수
    func getVisitor(
        id: Int,
        completion: @escaping (Result<VisitorDetailResponseDto, Error>)
        -> Void
    ) {
        provider.request(.getVisitor(id: id)) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("getVisitor 응답: \(json)")
                    }
                    let dto = try JSONDecoder().decode(
                        VisitorDetailResponseDto.self,
                        from: response.data
                    )
                    completion(.success(dto))
                } catch {
                    Log.error("디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case .failure(let error):
                if let data = error.response?.data,
                   let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                    let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(messages)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// UUID로 Visitor 정보 가져오기 함수
    func getVisitorByUUID(
        _ uuid: String,
        completion: @escaping (Result<VisitorDetailResponseDto, Error>)
        -> Void
    ) {
        provider.request(.getVisitorByUUID(uuid: uuid)) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("getVisitorByUUID 응답: \(json)")
                    }
                    let dto = try JSONDecoder().decode(
                        VisitorDetailResponseDto.self,
                        from: response.data
                    )
                    completion(.success(dto))
                } catch {
                    Log.error("디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case .failure(let error):
                if let data = error.response?.data,
                   let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                    let message = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validation Error: \(message)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
}

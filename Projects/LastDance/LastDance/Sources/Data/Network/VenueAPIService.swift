//
//  VenueAPIService.swift
//  LastDance
//
//  Created by 배현진 on 10/18/25.
//

import Foundation
import Moya

protocol VenueAPIServiceProtocol {
    func getVenues(
        completion: @escaping (Result<[VenueDetailResponseDto], Error>)
        -> Void
    )
    func getVenue(
        id: Int,
        completion: @escaping (Result<VenueDetailResponseDto, Error>)
        -> Void
    )
}

final class VenueAPIService: VenueAPIServiceProtocol {
    private let provider: MoyaProvider<VenueAPI>
    
    init(provider: MoyaProvider<VenueAPI> = MoyaProvider<VenueAPI>(
        plugins: [NetworkLoggerPlugin()])
    ) {
        self.provider = provider
    }
    
    /// 전체 Venue 목록 가져오기 함수
    func getVenues(
        completion: @escaping (Result<[VenueDetailResponseDto], Error>)
        -> Void
    ) {
        provider.request(.getVenues) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("Get Venues 요청 성공. 응답: \(json)")
                    }
                    let items = try JSONDecoder().decode(
                        [VenueDetailResponseDto].self,
                        from: response.data
                    )
                    
                    DispatchQueue.main.async {
                        items.forEach { dto in
                            let model = VenueMapper.toModel(from: dto)
                            SwiftDataManager.shared.upsertVenue(model)
                        }
                        // TODO: - 전체 Visitors 확인 용도 (이후에 제거 가능)
                        SwiftDataManager.shared.printAllVenues()
                    }
                    
                    completion(.success(items))
                } catch {
                    Log.error("디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingFailed))
                }
            case .failure(let error):
                if let data = error.response?.data,
                   let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                    let message = err.detail.map { $0.msg }.joined(separator: ", ")
                    Log.warning("Validtation Error: \(message)")
                }
                Log.error("API 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    /// id 정보로 특정 Venue 가져오기 함수
    func getVenue(
        id: Int,
        completion: @escaping (Result<VenueDetailResponseDto, any Error>)
        -> Void
    ) {
        provider.request(.getVenue(id: id)) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = String(data: response.data, encoding: .utf8) {
                        Log.debug("API 요청 성공. 응답: \(json)")
                    }
                    let dto = try JSONDecoder().decode(
                        VenueDetailResponseDto.self,
                        from: response.data)
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
                Log.error("API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }
}

// TODO: - develop 기능 머지 후 Mapper 폴더로 이동
enum VenueMapper {
    static func toModel(from dto: VenueDetailResponseDto) -> Venue {
        Venue(
            id: dto.id,
            name: dto.name,
            address: dto.address,
            geoLat: dto.geo_lat,
            geoLon: dto.geo_lon
        )
    }
}

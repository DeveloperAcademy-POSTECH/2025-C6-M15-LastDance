//
//  ClipVisitAPIService.swift
//  LastDance
//
//  Created by 배현진 on 11/12/25.
//
import Foundation
import Moya

protocol ClipVisitHistoriesAPIServiceProtocol {
    func createVisitHistory(visitorId: Int, exhibitionId: Int) async throws -> VisitorHistoriesResponseDto
    func getVisitHistories(visitorId: Int, exhibitionId: Int) async throws -> [VisitorHistoriesResponseDto]
    func ensureVisitId(visitorId: Int, exhibitionId: Int) async throws -> Int
}

final class ClipVisitHistoriesAPIService: ClipVisitHistoriesAPIServiceProtocol {
    private let provider: MoyaProvider<VisitHistoriesAPI>
    
    init(provider: MoyaProvider<VisitHistoriesAPI> = MoyaProvider<VisitHistoriesAPI>()) {
        self.provider = provider
    }
    
    // 방문 기록 생성
    func createVisitHistory(visitorId: Int, exhibitionId: Int) async throws -> VisitorHistoriesResponseDto {
        let dto = MakeVisitHistoriesRequestDto(visitor_id: visitorId, exhibition_id: exhibitionId)
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.makeVisitHistories(dto: dto)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(VisitorHistoriesResponseDto.self, from: response.data)
                        UserDefaults.standard.set(decoded.id, forKey: UserDefaultsKey.visitId.key)
                        continuation.resume(returning: decoded)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 방문 기록 조회
    func getVisitHistories(visitorId: Int, exhibitionId: Int) async throws -> [VisitorHistoriesResponseDto] {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getVisitHistories(visitorId: visitorId, exhibitionId: exhibitionId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode([VisitorHistoriesResponseDto].self, from: response.data)
                        continuation.resume(returning: decoded)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 있으면 기존 visit_id, 없으면 새로 생성
    func ensureVisitId(visitorId: Int, exhibitionId: Int) async throws -> Int {
        // UserDefaults에 이미 저장되어 있다면 그대로 사용
        if let cached = UserDefaults.standard.object(forKey: UserDefaultsKey.visitId.key) as? Int {
            return cached
        }
        
        // 서버에 기존 방문 내역이 있는지 확인
        do {
            let histories = try await getVisitHistories(visitorId: visitorId, exhibitionId: exhibitionId)
            if let first = histories.first {
                UserDefaults.standard.set(first.id, forKey: UserDefaultsKey.visitId.key)
                return first.id
            }
        } catch {
            Log.warning("방문 기록 조회 실패 (신규 방문으로 처리): \(error)")
        }
        
        // 없으면 새로 생성
        let created = try await createVisitHistory(visitorId: visitorId, exhibitionId: exhibitionId)
        return created.id
    }
}

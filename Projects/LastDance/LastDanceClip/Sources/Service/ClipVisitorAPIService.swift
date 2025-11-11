//
//  ClipVisitorAPIService.swift
//  LastDance
//
//  Created by 배현진 on 11/11/25.
//
import Foundation
import Moya

protocol ClipVisitorAPIServiceProtocol {
    /// UUID로 조회
    func loadVisitor(by uuid: String) async throws -> VisitorDetailResponseDto
    /// 새로 생성
    func createVisitor(request: VisitorCreateRequestDto) async throws -> VisitorDetailResponseDto
    /// uuid 기준으로 있으면 가져오고 없으면 만들기
    func ensureVisitorId(for uuid: String) async throws -> Int
}

final class ClipVisitorAPIService: ClipVisitorAPIServiceProtocol {
    private let provider: MoyaProvider<VisitorAPI>

    init(provider: MoyaProvider<VisitorAPI> = MoyaProvider<VisitorAPI>()) {
        self.provider = provider
    }

    // UUID로 조회
    func loadVisitor(by uuid: String) async throws -> VisitorDetailResponseDto {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<VisitorDetailResponseDto, Error>) in
            provider.request(.getVisitorByUUID(uuid: uuid)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try JSONDecoder().decode(VisitorDetailResponseDto.self, from: response.data)
                        continuation.resume(returning: dto)
                    } catch {
                        continuation.resume(throwing: error)
                    }

                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // 새 방문자 만들기
    func createVisitor(request: VisitorCreateRequestDto) async throws -> VisitorDetailResponseDto {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<VisitorDetailResponseDto, Error>) in
            provider.request(.createVisitor(dto: request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try JSONDecoder().decode(VisitorDetailResponseDto.self, from: response.data)
                        // App Clip에서도 다음 요청 때 쓰려고 저장해두면 좋음
                        UserDefaults.standard.set(dto.id, forKey: "visitorId")
                        UserDefaults.standard.set(dto.uuid, forKey: "visitorUUID")
                        continuation.resume(returning: dto)
                    } catch {
                        continuation.resume(throwing: error)
                    }

                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // 있으면 id만, 없으면 만들고 id
    func ensureVisitorId(for uuid: String) async throws -> Int {
        // UserDefaults에 있으면 사용
        if let savedId = UserDefaults.standard.object(forKey: UserDefaultsKey.visitorId.key) as? Int {
            return savedId
        }

        // 서버에 이미 이 uuid가 있는지 본다
        do {
            let existing = try await loadVisitor(by: uuid)
            UserDefaults.standard.set(existing.id, forKey: UserDefaultsKey.visitorId.key)
            return existing.id
        } catch {
            // 여기서 404면 새로 만들어야 하는 상황일 가능성이 큼
            // 다른 에러면 그대로 던져
            // Moya가 주는 error에서 statusCode를 뽑을 수 있으면 뽑아서 404만 잡아도 되고,
            // 귀찮으면 그냥 만들기 시도해도 됨
        }

        // 3) 없으니까 만든다
        let request = VisitorCreateRequestDto(uuid: uuid, name: nil)
        let created = try await createVisitor(request: request)
        return created.id
    }
}

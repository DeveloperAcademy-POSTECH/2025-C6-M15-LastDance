//
//  InvitationAPIService.swift
//  LastDance
//
//  Created by donghee on 11/17/25.
//

import Foundation
import Moya

// MARK: InvitationAPIServiceProtocol

protocol InvitationAPIServiceProtocol {
    func getInvitations(
        completion: @escaping (Result<[InvitationResponseDto], Error>) -> Void
    )
    func createInvitation(
        dto: InvitationRequestDto,
        completion: @escaping (Result<InvitationResponseDto, Error>) -> Void
    )
    func deleteInvitation(
        invitationId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func getInvitationByCode(
        code: String,
        completion: @escaping (Result<InvitationResponseDto, Error>) -> Void
    )
    func createInvitationInterest(
        invitationId: Int,
        completion: @escaping (Result<InvitationInterestResponseDto, Error>) -> Void
    )
}

// MARK: InvitationAPIService

final class InvitationAPIService: InvitationAPIServiceProtocol {
    private let provider: MoyaProvider<InvitationAPI>

    init(provider: MoyaProvider<InvitationAPI> = MoyaProvider<InvitationAPI>()) {
        self.provider = provider
    }

    /// 초대장 목록 조회 API
    func getInvitations(
        completion: @escaping (Result<[InvitationResponseDto], Error>) -> Void
    ) {
        // TODO: 서버 API 연동 필요
        Log.debug("초대장 목록 조회 API 호출")

        provider.request(.getInvitations) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("서버 응답: \(jsonString)")
                    }

                    let invitations = try JSONDecoder().decode(
                        [InvitationResponseDto].self, from: response.data
                    )

                    // 로컬에 저장 후 completion 호출
                    DispatchQueue.main.async {
                        for invitationDto in invitations {
                            let invitation = InvitationMapper.toModel(from: invitationDto)
                            SwiftDataManager.shared.upsertInvitation(invitation)
                        }
                        Log.debug("로컬 저장 완료: \(invitations.count)개")

                        // 저장 완료 후 completion 호출
                        completion(.success(invitations))
                    }
                } catch {
                    Log.fault("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                Log.error("API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 초대장 생성 API
    func createInvitation(
        dto: InvitationRequestDto,
        completion: @escaping (Result<InvitationResponseDto, Error>) -> Void
    ) {
        Log.debug("초대장 생성 API 호출 - exhibition_id: \(dto.exhibition_id), message: '\(dto.message)'")

        provider.request(.createInvitation(dto: dto)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("서버 응답 (\(response.statusCode)): \(jsonString)")
                    }

                    let invitation = try JSONDecoder().decode(
                        InvitationResponseDto.self, from: response.data
                    )
                    Log.debug(
                        "JSON 디코딩 성공 - invitation_id: \(invitation.id), message: '\(invitation.message ?? "nil")'"
                    )

                    // 로컬에 저장
                    let invitationEntity = InvitationMapper.toModel(from: invitation)
                    Log.debug(
                        "Entity 변환 완료 - id: \(invitationEntity.id), title: \(invitationEntity.exhibitionTitle)"
                    )

                    DispatchQueue.main.async {
                        SwiftDataManager.shared.upsertInvitation(invitationEntity)

                        // 저장 완료 후 completion 호출
                        completion(.success(invitation))
                    }
                } catch {
                    Log.fault("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let moyaError):
                if let response = moyaError.response {
                    // ErrorResponseDto로 먼저 디코딩 시도
                    if let errorDto = try? JSONDecoder().decode(ErrorResponseDto.self, from: response.data) {
                        Log.error("API 요청 실패 (상태 코드: \(response.statusCode))")
                        Log.error("에러 상세: \(errorDto.detail.map { $0.msg }.joined(separator: ", "))")
                    } else if let responseString = String(data: response.data, encoding: .utf8) {
                        Log.error("API 요청 실패 (상태 코드: \(response.statusCode))")
                        Log.error("서버 응답 내용: \(responseString)")
                        Log.error("요청 URL: \(response.request?.url?.absoluteString ?? "unknown")")
                    }
                } else {
                    Log.error("API 요청 실패: \(moyaError)")
                }
                completion(.failure(moyaError))
            }
        }
    }

    /// 초대장 삭제 API
    func deleteInvitation(
        invitationId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // TODO: 서버 API 연동 필요
        Log.debug("초대장 삭제 API 호출 - invitation_id: \(invitationId)")

        provider.request(.deleteInvitation(invitation_id: invitationId)) { result in
            switch result {
            case .success:
                // 로컬에서 삭제
                DispatchQueue.main.async {
                    SwiftDataManager.shared.deleteInvitation(id: invitationId)
                    Log.debug("초대장 삭제 완료")

                    // 삭제 완료 후 completion 호출
                    completion(.success(()))
                }
            case .failure(let error):
                Log.error("API 요청 실패: \(error)")
                completion(.failure(error))
            }
        }
    }

    /// 초대장 코드로 조회 API
    func getInvitationByCode(
        code: String,
        completion: @escaping (Result<InvitationResponseDto, Error>) -> Void
    ) {
        Log.debug("초대장 코드로 조회 API 호출 - code: \(code)")

        provider.request(.getInvitationByCode(code: code)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("서버 응답 (\(response.statusCode)): \(jsonString)")
                    }

                    let invitation = try JSONDecoder().decode(
                        InvitationResponseDto.self, from: response.data
                    )
                    Log.debug("초대장 조회 성공 - invitation_id: \(invitation.id)")

                    // 로컬에 저장
                    let invitationEntity = InvitationMapper.toModel(from: invitation)
                    DispatchQueue.main.async {
                        SwiftDataManager.shared.upsertInvitation(invitationEntity)
                        completion(.success(invitation))
                    }
                } catch {
                    Log.fault("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let moyaError):
                if let response = moyaError.response {
                    // ErrorResponseDto로 먼저 디코딩 시도
                    if let errorDto = try? JSONDecoder().decode(ErrorResponseDto.self, from: response.data) {
                        Log.error("API 요청 실패 (상태 코드: \(response.statusCode))")
                        Log.error("에러 상세: \(errorDto.detail.map { $0.msg }.joined(separator: ", "))")
                    } else if let responseString = String(data: response.data, encoding: .utf8) {
                        Log.error("API 요청 실패 (상태 코드: \(response.statusCode))")
                        Log.error("서버 응답 내용: \(responseString)")
                    }
                } else {
                    Log.error("API 요청 실패: \(moyaError)")
                }
                completion(.failure(moyaError))
            }
        }
    }

    /// 초대장 관심 표현 (갈게요) API
    func createInvitationInterest(
        invitationId: Int,
        completion: @escaping (Result<InvitationInterestResponseDto, Error>) -> Void
    ) {
        Log.debug("초대장 관심 표현 API 호출 - invitation_id: \(invitationId)")

        let dto = InvitationInterestRequestDto(invitation_id: invitationId)

        provider.request(.createInvitationInterest(dto: dto)) { result in
            switch result {
            case .success(let response):
                do {
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        Log.debug("서버 응답 (\(response.statusCode)): \(jsonString)")
                    }

                    let interest = try JSONDecoder().decode(
                        InvitationInterestResponseDto.self, from: response.data
                    )
                    Log.debug("관심 표현 성공 - interest_id: \(interest.id)")

                    DispatchQueue.main.async {
                        completion(.success(interest))
                    }
                } catch {
                    Log.fault("JSON 디코딩 실패: \(error)")
                    completion(.failure(error))
                }
            case .failure(let moyaError):
                if let response = moyaError.response {
                    // ErrorResponseDto로 먼저 디코딩 시도
                    if let errorDto = try? JSONDecoder().decode(ErrorResponseDto.self, from: response.data) {
                        Log.error("API 요청 실패 (상태 코드: \(response.statusCode))")
                        Log.error("에러 상세: \(errorDto.detail.map { $0.msg }.joined(separator: ", "))")
                    } else if let responseString = String(data: response.data, encoding: .utf8) {
                        Log.error("API 요청 실패 (상태 코드: \(response.statusCode))")
                        Log.error("서버 응답 내용: \(responseString)")
                    }

                    // 409 에러 (이미 관심 표현한 경우) 특별 처리
                    if response.statusCode == 409 {
                        Log.warning("이미 관심 표현한 초대장입니다.")
                    }
                } else {
                    Log.error("API 요청 실패: \(moyaError)")
                }
                completion(.failure(moyaError))
            }
        }
    }
}

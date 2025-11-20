//
//  ReceivedInvitationViewModel.swift
//  LastDance
//
//  Created by donghee on 11/19/25.
//

import Foundation

@MainActor
final class ReceivedInvitationViewModel: ObservableObject {
    @Published var invitation: Invitation?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isProcessingInterest: Bool = false

    private let invitationCode: String
    private let apiService: InvitationAPIServiceProtocol

    init(invitationCode: String, apiService: InvitationAPIServiceProtocol = InvitationAPIService())
    {
        self.invitationCode = invitationCode
        self.apiService = apiService
    }

    func loadInvitation() {
        isLoading = true
        errorMessage = nil

        apiService.getInvitationByCode(code: invitationCode) { result in
            Task { @MainActor in
                self.isLoading = false

                switch result {
                case .success(let invitationDto):
                    self.invitation = InvitationMapper.toModel(from: invitationDto)

                case .failure(let error):
                    Log.error("초대장 로드 실패: \(error)")
                    self.errorMessage = "초대장을 불러올 수 없습니다"
                }
            }
        }
    }

    func handleGoToExhibition(completion: @escaping (Bool) -> Void) {
        guard let invitation = invitation else {
            Log.error("초대장 정보가 없습니다")
            completion(false)
            return
        }

        isProcessingInterest = true

        apiService.createInvitationInterest(invitationId: invitation.id) { result in
            Task { @MainActor in
                self.isProcessingInterest = false

                switch result {
                case .success:
                    completion(true)

                case .failure(let error):
                    Log.error("관심 표현 실패: \(error)")
                    // 409 에러(중복)여도 전시 화면으로 이동
                    completion(true)
                }
            }
        }
    }
}

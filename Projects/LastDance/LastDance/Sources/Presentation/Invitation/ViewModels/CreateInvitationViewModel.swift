//
//  CreateInvitationViewModel.swift
//  LastDance
//
//  Created by donghee on 11/17/25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class CreateInvitationViewModel: ObservableObject {
    @Published var invitations: [Invitation] = []
    @Published var isLoading: Bool = false

    private let apiService: InvitationAPIServiceProtocol

    init(apiService: InvitationAPIServiceProtocol = InvitationAPIService()) {
        self.apiService = apiService
    }

    /// 로컬에서 초대장 목록 조회
    func loadInvitationsFromLocal() {
        let localInvitations = SwiftDataManager.shared.fetchAll(Invitation.self)
        self.invitations = localInvitations.sorted { $0.id > $1.id }
    }

    /// 최신 초대장 정보 가져오기
    func getLatestInvitation(invitationId: Int) -> Invitation? {
        let allInvitations = SwiftDataManager.shared.fetchAll(Invitation.self)
        return allInvitations.first(where: { $0.id == invitationId })
    }

    /// 서버에서 초대장 목록 조회
    func loadInvitationsFromServer() {
        isLoading = true

        // TODO: 서버 API 연동 필요
        apiService.getInvitations { [weak self] result in
            guard let self = self else { return }

            Task { @MainActor in
                self.isLoading = false

                switch result {
                case .success:
                    // 로컬에서 다시 로드 (upsert 되어 있음)
                    self.loadInvitationsFromLocal()
                case .failure(let error):
                    Log.error("초대장 목록 조회 실패: \(error)")
                }
            }
        }
    }
}

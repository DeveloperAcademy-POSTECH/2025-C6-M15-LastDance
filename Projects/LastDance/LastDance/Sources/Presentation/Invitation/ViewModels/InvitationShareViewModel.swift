//
//  InvitationShareViewModel.swift
//  LastDance
//
//  Created by donghee on 11/18/25.
//

import Foundation
import SwiftUI

@MainActor
final class InvitationShareViewModel: ObservableObject {
    @Published var invitation: Invitation
    @Published var showDeleteAlert: Bool = false
    @Published var showShareSheet: Bool = false

    private let apiService: InvitationAPIServiceProtocol

    init(invitation: Invitation, apiService: InvitationAPIServiceProtocol = InvitationAPIService())
    {
        self.invitation = invitation
        self.apiService = apiService
    }

    var shareMessage: String? {
        var message = InvitationConstants.shareMessageHeader
        message += String(localized: "전시: \(invitation.exhibitionTitle)\n")
        message += String(
            localized:
                "기간: \(Date.formatShortDateRange(start: invitation.startDate, end: invitation.endDate))\n"
        )

        if !invitation.invitationMessage.isEmpty {
            message += "\n\(invitation.invitationMessage)\n"
        }

        if let deepLink = invitation.deepLink, let appStoreLink = invitation.appStoreLink {
            message += "\n" + String(localized: "초대장 확인하기") + ":\n"
            message += deepLink
            message += "\n\n" + String(localized: "WoA 앱 다운로드") + ":\n"
            message += appStoreLink
        } else {
            message += "\n" + String(localized: "WoA 앱에서 확인하세요") + "\n"
            if let appStoreLink = invitation.appStoreLink {
                message += appStoreLink
            } else {
                message += InvitationConstants.appStoreURL
            }
        }

        return message
    }

    func handleShare() {
        // 기존 초대장 정보 다시 가져오기
        fetchInvitationLinks()
    }

    private func fetchInvitationLinks() {
        apiService.getInvitations { result in
            Task {
                switch result {
                case .success(let invitations):
                    // 현재 초대장 ID와 일치하는 초대장 찾기
                    if let updatedInvitation = invitations.first(where: {
                        $0.id == self.invitation.id
                    }) {
                        // 링크 업데이트
                        self.invitation.deepLink = updatedInvitation.deep_link
                        self.invitation.appStoreLink = updatedInvitation.app_store_link

                        // 공유 시트 표시
                        self.showShareSheet = true
                    } else {
                        Log.error("초대장을 찾을 수 없습니다 - ID: \(self.invitation.id)")
                    }

                case .failure(let error):
                    Log.error("초대장 정보 조회 실패: \(error)")
                }
            }
        }
    }

    func handleDelete() {
        showDeleteAlert = true
    }

    func confirmDelete(completion: @escaping (Bool) -> Void) {
        apiService.deleteInvitation(invitationId: invitation.id) { result in
            Task {
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    Log.error("초대장 삭제 실패 - ID: \(self.invitation.id), Error: \(error)")
                    completion(false)
                }
            }
        }
    }
}

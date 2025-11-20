//
//  InvitationDetailViewModel.swift
//  LastDance
//
//  Created by donghee on 11/17/25.
//

import Foundation
import SwiftUI

@MainActor
final class InvitationDetailViewModel: ObservableObject {
    @Published var exhibition: Exhibition
    @Published var invitationMessage: String = ""
    @Published var isTextInputSheetPresented: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var showShareSheet: Bool = false
    @Published var createdInvitation: Invitation?
    @Published var invitationLinks: InvitationLinks?

    private let maxCharacterCount = 20
    private let apiService: InvitationAPIServiceProtocol

    struct InvitationLinks {
        let deepLink: String
        let appStoreLink: String
    }

    init(exhibition: Exhibition, apiService: InvitationAPIServiceProtocol = InvitationAPIService())
    {
        self.exhibition = exhibition
        self.apiService = apiService
    }

    private var invitationId: Int? {
        // 해당 전시의 초대장 ID 찾기
        SwiftDataManager.shared.fetchAll(Invitation.self)
            .first(where: { $0.exhibitionId == exhibition.id })?.id
    }

    var characterCount: Int {
        invitationMessage.count
    }

    var isMaxCharacterReached: Bool {
        invitationMessage.count >= maxCharacterCount
    }

    var venueName: String {
        guard let venueId = exhibition.venueId else { return "전시 장소 정보" }
        let venues = SwiftDataManager.shared.fetchAll(Venue.self)
        if let venue = venues.first(where: { $0.id == venueId }) {
            if let address = venue.address {
                return "\(venue.name) \(address)"
            }
            return venue.name
        }
        return "전시 장소 정보"
    }

    var artistName: String {
        // exhibition의 첫 번째 artwork에서 artistId 가져오기
        guard let firstArtwork = exhibition.artworks.first,
            let artistId = firstArtwork.artistId
        else { return "작가명" }

        let artists = SwiftDataManager.shared.fetchAll(Artist.self)
        if let artist = artists.first(where: { $0.id == artistId }) {
            return artist.name
        }
        return "작가명"
    }

    func updateMessage(_ text: String) {
        if text.count <= maxCharacterCount {
            invitationMessage = text
        }
    }

    func handleShare() {
        // 초대장 생성 API 호출 후 공유 시트 표시
        createInvitation()
    }

    private func createInvitation() {
        // UserDefaults 값 확인
        let artistId =
            UserDefaults.standard.object(forKey: UserDefaultsKey.artistId.rawValue) as? Int
        let artistUUID = UserDefaults.standard.string(forKey: UserDefaultsKey.artistUUID.rawValue)
        let artistName = UserDefaults.standard.string(forKey: UserDefaultsKey.artistName.rawValue)

        Log.debug("===== 초대장 생성 시작 =====")
        Log.debug("artistId: \(artistId?.description ?? "nil")")
        Log.debug("artistUUID: \(artistUUID ?? "nil")")
        Log.debug("artistName: \(artistName ?? "nil")")
        Log.debug("exhibition_id: \(exhibition.id)")
        Log.debug("invitation_message: \(invitationMessage)")
        Log.debug("========================")

        // UUID가 비어있으면 에러 처리
        if let uuid = artistUUID, uuid.isEmpty {
            Log.error("⚠️ artistUUID가 빈 문자열입니다. UserDefaults에서 삭제하고 작가 인증 코드로 다시 로그인하세요.")
            UserDefaults.standard.removeObject(forKey: UserDefaultsKey.artistUUID.rawValue)
            Log.debug("빈 artistUUID를 UserDefaults에서 삭제했습니다. 앱을 재시작하고 작가 인증 코드로 로그인하세요.")
            return
        }

        let dto = InvitationRequestDto(
            exhibition_id: exhibition.id,
            message: invitationMessage
        )

        apiService.createInvitation(dto: dto) { result in
            Task { @MainActor in
                switch result {
                case .success(let invitationDto):
                    Log.debug("초대장 생성 성공: \(invitationDto.id)")
                    // 로컬에 자동 저장됨 (APIService에서 처리)
                    Log.info(invitationDto.deep_link ?? "nil")
                    Log.info(invitationDto.app_store_link ?? "nil")

                    // 딥링크와 앱스토어 링크 저장
                    if let deepLink = invitationDto.deep_link,
                        let appStoreLink = invitationDto.app_store_link
                    {
                        self.invitationLinks = InvitationLinks(
                            deepLink: deepLink,
                            appStoreLink: appStoreLink
                        )
                    }

                    // 저장 확인용 로그
                    let invitations = SwiftDataManager.shared.fetchAll(Invitation.self)
                    Log.debug("현재 로컬에 저장된 초대장 수: \(invitations.count)")

                    // 링크 저장 후 공유 시트 표시
                    self.showShareSheet = true

                case .failure(let error):
                    Log.error("초대장 생성 실패: \(error)")
                }
            }
        }
    }

    func getShareMessage() -> String {
        var message = "🎨 전시 초대장이 도착했습니다!\n\n"
        message += "전시: \(exhibition.title)\n"
        message +=
            "기간: \(Date.formatShortDateRange(start: exhibition.startDate, end: exhibition.endDate))\n"

        if !invitationMessage.isEmpty {
            message += "\n\(invitationMessage)\n"
        }

        if let links = invitationLinks {
            message += "\n초대장 확인하기:\n"
            message += links.deepLink
            message += "\n\nWoA 앱 다운로드:\n"
            message += links.appStoreLink
        } else {
            message += "\nWoA 앱에서 확인하세요\n"
            message += "https://apps.apple.com/kr/app/%EC%97%AC%EC%9A%B4/id6754415794"
        }

        return message
    }

    func handleDelete() {
        showDeleteAlert = true
    }

    func confirmDelete(completion: @escaping (Bool) -> Void) {
        guard let invitationId = invitationId else {
            Log.error("초대장 ID를 찾을 수 없습니다.")
            completion(false)
            return
        }

        Log.debug("초대장 삭제 시작 - ID: \(invitationId)")

        apiService.deleteInvitation(invitationId: invitationId) { result in
            Task { @MainActor in
                switch result {
                case .success:
                    Log.debug("초대장 삭제 성공 - ID: \(invitationId)")
                    completion(true)
                case .failure(let error):
                    Log.error("초대장 삭제 실패 - ID: \(invitationId), Error: \(error)")
                    completion(false)
                }
            }
        }
    }
}

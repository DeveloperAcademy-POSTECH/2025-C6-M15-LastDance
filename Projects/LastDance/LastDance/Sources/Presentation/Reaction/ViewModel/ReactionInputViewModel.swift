//
//  ReactionInputViewModel.swift
//  LastDance
//
//  Created by 신얀 on 10/15/25.
//

import Combine
import Moya
import SwiftData
import SwiftUI

@MainActor
final class ReactionInputViewModel: ObservableObject, SendThrottleHandler {
    @Published var message: String = ""  // 반응을 남기기 위한 textEditor 메세지
    @Published var selectedArtworkTitle: String = ""  // 선택한 작품 제목
    @Published var selectedArtistName: String = ""  // 선택한 작가 이름
    @Published var capturedImage: UIImage?  // 촬영한 이미지
    @Published var shouldShowConfirmAlert = false
    @Published var shouldTriggerSend = false
    @Published var alertType: AlertType = .confirmation
    @Published private(set) var forceDisableSendButton = false

    let limit = ReactionConstants.maxMessageLength

    let profanity = ProfanityFilter.fromBundle()
    var selectedArtworkId: Int?  // 선택한 작품 ID (내부 저장용)
    var selectedArtistId: Int?  // 선택한 작가 ID (내부 저장용)

    // TODO: - 프로토콜 사용 적용하기
    private let dataManager = SwiftDataManager.shared
    private let apiService = ReactionAPIService()
    private let artworkAPIService = ArtworkAPIService()
    private let artistAPIService = ArtistAPIService()
    private let notificationService = NotificationAPIService()

    private let throttleInterval: TimeInterval = 2.0
    private lazy var throttle = SendThrottle(
        throttleInterval: throttleInterval,
        handler: self
    )

    init() {}

    // 하단버튼 유효성 검사
    var isSendButtonDisabled: Bool {
        message.isEmpty || forceDisableSendButton
    }

    // 제한 알럿에서 "다시 작성하기" 눌러 닫힐 때 호출
    func handleRestrictionAlertDismiss() {
        forceDisableSendButton = true
    }

    // 하단 "전송하기" 버튼 탭
    func sendButtonAction() {
        Log.debug("전송 버튼 탭 이벤트 발생")
        throttle.sendButtonAction()
    }

    // Alert 내부 "전송하기" 버튼 탭
    func confirmSendAction() {
        Log.debug("Alert 전송 버튼 탭 이벤트 발생")
        throttle.confirmSendAction()
    }

    // 텍스트 길이 제한 로직
    func updateMessage(newValue: String) {
        // 사용자가 한단어라도 글자를 바꾸는 순간 재활성화
        if forceDisableSendButton {
            forceDisableSendButton = false
        }

        if newValue.count > limit {
            message = String(newValue.prefix(limit))
        } else {
            message = newValue
        }
    }

    /// 인식된 작품의 작품명과 작가 정보를 저장하는 함수
    func setArtworkInfo(
        artworkTitle: String, artistName: String, artworkId: Int, artistId: Int,
        completion: @escaping (Bool) -> Void
    ) {
        selectedArtworkTitle = artworkTitle
        selectedArtistName = artistName
        selectedArtworkId = artworkId
        selectedArtistId = artistId

        // SwiftData에서 작품의 artistId 업데이트
        dataManager.updateArtworkArtist(artworkId: artworkId, artistId: artistId)

        Log.debug(
            "작품 정보 설정 - 작품: \(artworkTitle), 작가: \(artistName), 작품ID: \(artworkId), 작가ID: \(artistId)"
        )
        completion(true)
    }

    /// 작품 반응을 저장하는 함수
    func saveReaction(
        artworkId: Int, visitorId: Int, visitId: Int, imageData: Data,
        completion: @escaping (Bool) -> Void
    ) {
        let dto = ReactionRequestDto(
            artworkId: artworkId,
            visitorId: visitorId,
            visitId: visitId,
            comment: message.isEmpty ? nil : message,
            imageData: imageData,
            tagIds: []
        )

        apiService.createReaction(dto: dto) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.message = ""
                    Log.debug("반응 저장 성공")

                    // 첫 리액션 등록 플래그 저장
                    if !UserDefaults.standard.bool(forKey: .hasRegisteredFirstReaction) {
                        UserDefaults.standard.set(true, forKey: .hasRegisteredFirstReaction)
                    }

                    // 작가에게 푸시알림 전송
                    self.sendPushNotificationToArtist(reactionResponse: response.data)

                    completion(true)

                case .failure(let error):
                    Log.debug("반응 저장 실패: \(error)")
                    completion(false)
                }
            }
        }
    }

    /// UserDefaults, SwiftData 접근 및 검증 메서드
    func performSendReaction(
        artworkId: Int, exhibitionId: Int?, completion: @escaping (Bool, Int?) -> Void
    ) {
        // 사진(UIImage) → Data 변환
        guard
            let image = capturedImage,
            let imageData = image.jpegData(compressionQuality: 0.8)
        else {
            Log.warning("capturedImage가 없거나 Data 변환에 실패했습니다.")
            alertType = .error
            shouldShowConfirmAlert = true
            completion(false, nil)
            return
        }

        // UserDefaults에서 저장된 visitorUUID 가져오기
        guard
            let visitorUUID = UserDefaults.standard.string(
                forKey: UserDefaultsKey.visitorUUID.rawValue)
        else {
            Log.warning("visitorUUID를 찾을 수 없습니다")
            alertType = .error
            shouldShowConfirmAlert = true
            completion(false, nil)
            return
        }

        // SwiftData에서 UUID로 Visitor 조회
        let visitors = SwiftDataManager.shared.fetchAll(Visitor.self)
        guard let visitor = visitors.first(where: { $0.uuid == visitorUUID }) else {
            Log.warning("Visitor를 찾을 수 없습니다")
            alertType = .error
            shouldShowConfirmAlert = true
            completion(false, nil)
            return
        }

        // 현재 작품이 속한 전시 ID 찾기
        let artworks = SwiftDataManager.shared.fetchAll(Artwork.self)
        guard let currentArtwork = artworks.first(where: { $0.id == artworkId }) else {
            Log.warning("현재 Artwork을 찾을 수 없습니다. (exhibitionId 파악 불가)")
            alertType = .error
            shouldShowConfirmAlert = true
            completion(false, nil)
            return
        }

        // UserDefaults에서 visitId 가져오기
        guard
            let visitId = UserDefaults.standard.object(
                forKey: UserDefaultsKey.visitId.key
            ) as? Int
        else {
            Log.warning("visitId를 UserDefaults에서 찾을 수 없습니다.")
            alertType = .error
            shouldShowConfirmAlert = true
            completion(false, nil)
            return
        }

        let visitorId = visitor.id

        saveReaction(
            artworkId: artworkId,
            visitorId: visitorId,
            visitId: visitId,
            imageData: imageData
        ) { [weak self] success in
            guard let self = self else { return }

            if success {
                Log.debug("저장 성공, 화면 이동")
                self.shouldShowConfirmAlert = false
                completion(true, exhibitionId ?? 1)
            } else {
                Log.debug("저장 실패")
                self.alertType = .error
                completion(false, nil)
            }
        }
    }

    // TODO: 실제데이터 연동 후 파라미터 교체 예정
    func getReactionsAPI(artworkId: Int) {
        Log.debug("반응 조회 API 테스트 시작")

        apiService.getReactions(artworkId: artworkId, visitorId: nil, visitId: nil) { result in
            switch result {
            case .success(let reactions):
                Log.debug("반응 조회 성공! 조회된 반응 수: \(reactions.count)")
            case .failure(let error):
                Log.debug("반응 조회 실패: \(error)")
            }
        }
    }

    /// 반응 상세 조회 API 함수
    func getDetailReactionAPI(reactionId: Int) {
        Log.debug("반응 상세 조회 API 테스트 시작 - reactionId: \(reactionId)")

        apiService.getDetailReaction(reactionId: reactionId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    Log.debug("반응 상세 조회 성공!")
                case .failure(let error):
                    Log.debug("반응 상세 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 작품 목록 조회 API 함수
    func fetchArtworks(artistId: Int? = nil, exhibitionId: Int? = nil) {
        Log.debug(
            "작품 목록 조회 API 호출 - artistId: \(String(describing: artistId)), exhibitionId: \(String(describing: exhibitionId))"
        )

        artworkAPIService.getArtworks(artistId: artistId, exhibitionId: exhibitionId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let artworks):
                    Log.debug("작품 목록 조회 성공! 조회된 작품 수: \(artworks.count)")
                case .failure(let error):
                    Log.error("작품 목록 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    func fetchAllArtists() {
        Log.debug("작가 목록 조회 API 호출")
        artistAPIService.getArtists { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let artists):
                    Log.debug("작가 목록 조회 성공! 조회된 작가 수: \(artists.count)")
                case .failure(let error):
                    Log.error("작가 목록 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Push Notification

extension ReactionInputViewModel {
    /// 작가에게 푸시알림 전송
    private func sendPushNotificationToArtist(reactionResponse: ReactionDetailResponseDto) {
        let artistId = reactionResponse.artwork.artist_id

        Log.debug("작가(\(artistId))에게 푸시알림 전송 시작")

        let pushDto = SendNotificationRequestDto(
            visitor_id: nil,  // 작가에게만 알림 전송
            artist_id: artistId,
            device_token: nil,
            title: "내 작품에 새로운 메시지가 있어요",
            body: "어떤 메시지인지 확인해보세요!",
            data: nil,
            badge: 1,
            use_sandbox: true  // TODO: 배포 시 false로 변경
        )

        notificationService.sendNotification(dto: pushDto) { result in
            switch result {
            case .success(let response):
                Log.debug(
                    "푸시알림 전송 성공 - success: \(response.success_count), failed: \(response.failed_count)"
                )
            case .failure(let error):
                Log.error("푸시알림 전송 실패: \(error.localizedDescription)")
            }
        }
    }
}

//
//  ArtReactionViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/21/25.
//

import SwiftData
import SwiftUI

@MainActor
final class ArtReactionViewModel: ObservableObject, SendThrottleHandler {

    // MARK: - Properties

    @Published var reactions: [Reaction] = []
    @Published var isLoading = false
    @Published var message: String = ""  // 반응을 남기기 위한 textEditor 메세지
    @Published var capturedImageData: Data?  // 촬영한 이미지
    @Published private(set) var forceDisableSendButton = false
    @Published var shouldShowConfirmAlert = false
    @Published var shouldTriggerSend = false
    @Published var alertType: AlertType = .confirmation
    @Published var artwork: Artwork?
    @Published var artist: Artist?
    @Published var isSending = false

    let limit = ReactionConstants.maxMessageLength
    let profanity = ProfanityFilter.fromBundle()

    private let artworkId: Int
    private let swiftDataManager = SwiftDataManager.shared
    private let dataManager = SwiftDataManager.shared
    private let apiService = ReactionAPIService()
    private let artworkService = ArtworkAPIService()
    private let artistService = ArtistAPIService()
    private let visitHistoriesService = VisitHistoriesAPIService()
    private let notificationService = NotificationAPIService()

    private let throttleInterval: TimeInterval = 2.0
    private lazy var throttle = SendThrottle(
        throttleInterval: throttleInterval,
        handler: self
    )

    // MARK: - Initialization

    init(artworkId: Int) {
        self.artworkId = artworkId
    }

    var hasText: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 하단 전송 버튼 활성화 여부
    var isSendButtonDisabled: Bool {
        !hasText || isSending || forceDisableSendButton
    }

    // 제한 알럿에서 "다시 작성하기" 눌러 닫힐 때 호출
    func handleRestrictionAlertDismiss() {
        forceDisableSendButton = true
    }

    // MARK: - Public Methods

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

    func loadReactions() {
        isLoading = true

        guard let container = swiftDataManager.container else {
            isLoading = false
            return
        }

        let context = container.mainContext

        do {
            let targetId = artworkId
            let predicate = #Predicate<Reaction> { reaction in
                reaction.artworkId == targetId
            }
            let descriptor = FetchDescriptor<Reaction>(predicate: predicate)
            reactions = try context.fetch(descriptor)
        } catch {
            Log.error("Failed to load reactions: \(error)")
        }
        isLoading = false
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

    /// 작품 반응을 저장하는 함수
    func sendReaction(
        artworkId: Int, visitorId: Int, visitId: Int, imageData: Data,
        completion: @escaping (Bool) -> Void
    ) {
        isSending = true

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
                self.isSending = false

                switch result {
                case .success(let response):
                    self.message = ""

                    // 첫 리액션 등록 플래그 저장
                    if !UserDefaults.standard.bool(forKey: .hasRegisteredFirstReaction) {
                        UserDefaults.standard.set(true, forKey: .hasRegisteredFirstReaction)
                    }

                    // 작가에게 푸시알림 전송
                    // TODO: - sendPushNotificationToArtist 말고 다른 방식으로 변경
                    //                    self.sendPushNotificationToArtist(reactionResponse: response.data)

                    completion(true)

                case .failure(let error):
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
            let imageData = capturedImageData
        else {
            Log.warning("capturedImage가 없습니다.")
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

        sendReaction(
            artworkId: artworkId,
            visitorId: visitorId,
            visitId: visitId,
            imageData: imageData
        ) { [weak self] success in
            guard let self = self else { return }

            if success {
                self.shouldShowConfirmAlert = false
                completion(true, exhibitionId ?? 1)
            } else {
                Log.debug("저장 실패")
                self.alertType = .error
                completion(false, nil)
            }
        }
    }

    /// Artwork 상세 조회
    func fetchArtworkDetail(artworkId: Int, exhibitionId: Int) {
        artworkService.getArtworkDetail(artworkId: artworkId) { result in
            Task {
                switch result {
                case .success(let dto):
                    Log.debug("작품 상세 조회 성공! 작품명: \(dto.title)")
                    let artwork = ArtworkMapper.mapDtoToModel(dto, exhibitionId: exhibitionId)
                    self.artwork = artwork

                case .failure(let error):
                    Log.error("작품 상세 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Artist 상세 조회
    func fetchArtistDetail(artistId: Int) {
        artistService.getArtist(id: artistId) { result in
            Task {
                switch result {
                case .success(let dto):
                    Log.debug("작가 상세 조회 성공! 작가명: \(dto.name)")

                    let artist = ArtistMapper.toModel(from: dto)
                    self.artist = artist

                case .failure(let error):
                    Log.error("작가 상세 조회 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}

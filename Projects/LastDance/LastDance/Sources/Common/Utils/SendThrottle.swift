//
//  SendThrottle.swift
//  LastDance
//
//  Created by 배현진 on 11/14/25.
//

import Combine
import Foundation

/// SendThrottle 사용을 위한 공통 프로토콜
@MainActor
protocol SendThrottleHandler: AnyObject {
    var profanity: ProfanityFilter { get }
    var message: String { get }
    var alertType: AlertType { get set }
    var shouldShowConfirmAlert: Bool { get set }
    var shouldTriggerSend: Bool { get set }

    func handleSendButtonAllowed()
    func handleConfirmSendAllowed()
}

extension SendThrottleHandler {
    func handleSendButtonAllowed() {
        let hasProfanity = profanity.containsProfanity(in: message)
        alertType = hasProfanity ? .restriction : .confirmation
        shouldShowConfirmAlert = true
    }

    func handleConfirmSendAllowed() {
        Log.debug("ClipArt Alert 전송 버튼 스로틀링 통과 - 실제 전송 트리거")
        shouldTriggerSend = true
    }
}

/// 전송 버튼 / Confirm 버튼에 공통으로 쓰는 쓰로틀 헬퍼
@MainActor
final class SendThrottle {
    private let throttleInterval: TimeInterval
    private var cancellables = Set<AnyCancellable>()

    private let sendButtonTapped = PassthroughSubject<Void, Never>()
    private let confirmSendTapped = PassthroughSubject<Void, Never>()

    private weak var handler: (any SendThrottleHandler)?

    init(
        throttleInterval: TimeInterval = 2.0,
        handler: some SendThrottleHandler
    ) {
        self.throttleInterval = throttleInterval
        self.handler = handler

        // 하단 전송 버튼 쓰로틀링
        sendButtonTapped
            .throttle(for: .seconds(throttleInterval), scheduler: RunLoop.main, latest: false)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handler?.handleSendButtonAllowed()
            }
            .store(in: &cancellables)

        // Alert 내 전송 버튼 쓰로틀링
        confirmSendTapped
            .throttle(for: .seconds(throttleInterval), scheduler: RunLoop.main, latest: false)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handler?.handleConfirmSendAllowed()
            }
            .store(in: &cancellables)
    }

    func sendButtonAction() {
        sendButtonTapped.send()
    }

    func confirmSendAction() {
        confirmSendTapped.send()
    }
}

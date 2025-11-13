//
//  SendThrottle.swift
//  LastDance
//
//  Created by 배현진 on 11/14/25.
//

import Combine
import Foundation

/// 전송 버튼 / Confirm 버튼에 공통으로 쓰는 쓰로틀 헬퍼
final class SendThrottle {
    private let throttleInterval: TimeInterval
    private var cancellables = Set<AnyCancellable>()
    
    private let sendButtonTapped = PassthroughSubject<Void, Never>()
    private let confirmSendTapped = PassthroughSubject<Void, Never>()
    
    init(
        throttleInterval: TimeInterval = 2.0,
        onSendButtonAllowed: @escaping () -> Void,
        onConfirmSendAllowed: @escaping () -> Void
    ) {
        self.throttleInterval = throttleInterval
        
        // 하단 전송 버튼 쓰로틀링
        sendButtonTapped
            .throttle(for: .seconds(throttleInterval), scheduler: RunLoop.main, latest: false)
            .receive(on: DispatchQueue.main)
            .sink {
                onSendButtonAllowed()
            }
            .store(in: &cancellables)
        
        // Alert 내 전송 버튼 쓰로틀링
        confirmSendTapped
            .throttle(for: .seconds(throttleInterval), scheduler: RunLoop.main, latest: false)
            .receive(on: DispatchQueue.main)
            .sink {
                onConfirmSendAllowed()
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

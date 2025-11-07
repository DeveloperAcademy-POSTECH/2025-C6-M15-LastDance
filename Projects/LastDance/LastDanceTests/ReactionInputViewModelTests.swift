//
//  ReactionInputViewModelTests.swift
//  LastDanceTests
//
//  Created by 신얀 on 11/7/25.
//

//
//  ReactionInputViewModelTests.swift
//  LastDanceTests
//
//  Created by 신얀 on 11/7/25.
//

import Combine
import Foundation
import Testing
@testable import LastDance 

@MainActor
@Suite("ReactionInputViewModel Throttling Tests")
struct ReactionInputViewModelTests {
    
    @Test("2초 이내 5번 연속 탭 시 첫 번째만 처리됨")
    func throttleMultipleTapsWithin2Seconds() async throws {
        // Given
        let sut = ReactionInputViewModel()
        var cancellables = Set<AnyCancellable>()
        var alertShownCount = 0

        sut.$shouldShowConfirmAlert
            .dropFirst() // 초기값 무시
            .sink { isShown in
                if isShown {
                    alertShownCount += 1
                }
            }
            .store(in: &cancellables)

        try await Task.sleep(nanoseconds: 100_000_000)

        // When: 5번 즉시 연타 (시간 간격 최소화)
        for _ in 0..<5 {
            sut.sendButtonAction()
        }
        try await Task.yield()

        // Then
        try await Task.sleep(nanoseconds: 1_200_000_000)

        #expect(alertShownCount == 1, "2초 이내 연속 탭 시 첫 번째만 처리되어야 함")
    }

    // 2.0초 간격 탭 테스트
    @Test("2초 간격으로 탭하면 각각 처리됨")
    func processEachTapAfter2Seconds() async throws {
        // Given
        let sut = ReactionInputViewModel()
        var cancellables = Set<AnyCancellable>()
        var alertShownCount = 0

        sut.$shouldShowConfirmAlert
            .dropFirst()
            .sink { isShown in
                if isShown {
                    alertShownCount += 1
                }
            }
            .store(in: &cancellables)

        // When
        sut.sendButtonAction()
        try await Task.yield()

        // 2.1초 후 두 번째 탭 (쓰로틀링 통과)
        try await Task.sleep(nanoseconds: 2_100_000_000)
        sut.sendButtonAction()
        try await Task.yield()

        // Then
        try await Task.sleep(nanoseconds: 500_000_000)

        #expect(alertShownCount == 2, "2초 간격으로 탭하면 각각 처리되어야 함")
    }

    // Alert 닫은 후 재시도 테스트
    @Test("Alert 닫은 후 2초 뒤 다시 탭하면 처리됨")
    func allowNewTapAfterClosingAlert() async throws {
        // Given
        let sut = ReactionInputViewModel()
        var cancellables = Set<AnyCancellable>()
        var alertShownCount = 0

        sut.$shouldShowConfirmAlert
            .dropFirst()
            .sink { isShown in
                if isShown {
                    alertShownCount += 1
                }
            }
            .store(in: &cancellables)

        // When: 첫 번째 탭
        sut.sendButtonAction()
        try await Task.yield()

        try await Task.sleep(nanoseconds: 500_000_000)
        sut.shouldShowConfirmAlert = false
        try await Task.yield()

        // 2초 후 다시 탭
        try await Task.sleep(nanoseconds: 2_000_000_000)
        sut.sendButtonAction()
        try await Task.yield()

        // Then: 0.5초 대기 후 확인
        try await Task.sleep(nanoseconds: 500_000_000)

        #expect(alertShownCount == 2, "Alert 닫은 후 2초 뒤 탭하면 다시 처리되어야 함")
    }

    // 10번 연타 테스트: 첫 번째만 처리되어야 함
    @Test("10번 연타 시 첫 번째만 처리됨")
    func onlyProcessFirstWhen10RapidTaps() async throws {
        // Given
        let sut = ReactionInputViewModel()
        var cancellables = Set<AnyCancellable>()
        var alertShownCount = 0

        sut.$shouldShowConfirmAlert
            .dropFirst()
            .sink { isShown in
                if isShown {
                    alertShownCount += 1
                }
            }
            .store(in: &cancellables)

        // 구독 준비 대기
        try await Task.sleep(nanoseconds: 100_000_000)

        // When: 10번 즉시 연타
        for _ in 0..<10 {
            sut.sendButtonAction()
        }
        try await Task.yield()

        // Then
        try await Task.sleep(nanoseconds: 1_200_000_000)

        #expect(alertShownCount == 1, "10번 연타해도 첫 번째만 처리되어야 함")
    }

    // 극단적 연타 테스트: 첫 번째만 처리되어야 함
    @Test("0.01초 간격 20번 연타 시 첫 번째만 처리됨")
    func extremeRapidFire20Taps() async throws {
        // Given
        let sut = ReactionInputViewModel()
        var cancellables = Set<AnyCancellable>()
        var alertShownCount = 0

        sut.$shouldShowConfirmAlert
            .dropFirst()
            .sink { isShown in
                if isShown {
                    alertShownCount += 1
                }
            }
            .store(in: &cancellables)

        // 구독 준비 대기
        try await Task.sleep(nanoseconds: 100_000_000)

        // When: 20번 즉시 연타
        for _ in 0..<20 {
            sut.sendButtonAction()
        }
        try await Task.yield()

        // Then
        try await Task.sleep(nanoseconds: 1_200_000_000)

        #expect(alertShownCount == 1, "초고속 20번 연타해도 첫 번째만 처리되어야 함")
    }

    @Test("Alert 전송 버튼 2초 이내 5번 연타 시 첫 번째만 처리됨")
    func confirmButtonThrottleMultipleTapsWithin2Seconds() async throws {
        // Given
        let sut = ReactionInputViewModel()
        var cancellables = Set<AnyCancellable>()
        var triggerCount = 0

        sut.$shouldTriggerSend
            .dropFirst()
            .sink { isTriggered in
                if isTriggered {
                    triggerCount += 1
                    sut.shouldTriggerSend = false
                }
            }
            .store(in: &cancellables)

        // 구독 준비 대기
        try await Task.sleep(nanoseconds: 100_000_000)

        // When: 5번 즉시 연타
        for _ in 0..<5 {
            sut.confirmSendAction()
        }
        try await Task.yield()

        // Then
        try await Task.sleep(nanoseconds: 1_200_000_000)

        #expect(triggerCount == 1, "Alert 전송 버튼 2초 이내 연타 시 첫 번째만 처리되어야 함")
    }

    // Alert 전송 버튼 2초 간격 테스트
    @Test("Alert 전송 버튼 2초 간격으로 탭하면 각각 처리됨")
    func confirmButtonProcessEachTapAfter2Seconds() async throws {
        // Given
        let sut = ReactionInputViewModel()
        var cancellables = Set<AnyCancellable>()
        var triggerCount = 0

        sut.$shouldTriggerSend
            .dropFirst()
            .sink { isTriggered in
                if isTriggered {
                    triggerCount += 1
                    sut.shouldTriggerSend = false
                }
            }
            .store(in: &cancellables)

        // When: 첫 번째 탭
        sut.confirmSendAction()
        try await Task.yield()

        try await Task.sleep(nanoseconds: 2_100_000_000)
        sut.confirmSendAction()
        try await Task.yield()

        // Then: 0.5초 대기 후 확인
        try await Task.sleep(nanoseconds: 500_000_000)

        #expect(triggerCount == 2, "Alert 전송 버튼 2초 간격으로 탭하면 각각 처리되어야 함")
    }

    // Alert 전송 버튼 10번 연타 테스트
    @Test("Alert 전송 버튼 10번 연타 시 첫 번째만 처리됨")
    func confirmButtonOnlyProcessFirstWhen10RapidTaps() async throws {
        // Given
        let sut = ReactionInputViewModel()
        var cancellables = Set<AnyCancellable>()
        var triggerCount = 0

        sut.$shouldTriggerSend
            .dropFirst()
            .sink { isTriggered in
                if isTriggered {
                    triggerCount += 1
                    sut.shouldTriggerSend = false
                }
            }
            .store(in: &cancellables)

        // 구독 준비 대기
        try await Task.sleep(nanoseconds: 100_000_000)

        // When: 10번 즉시 연타
        for _ in 0..<10 {
            sut.confirmSendAction()
        }
        try await Task.yield()

        // Then: 1.2초 대기 후 확인
        try await Task.sleep(nanoseconds: 1_200_000_000)

        #expect(triggerCount == 1, "Alert 전송 버튼 10번 연타해도 첫 번째만 처리되어야 함")
    }

    // Alert 전송 버튼 극단적 연타 테스트
    @Test("Alert 전송 버튼 0.01초 간격 20번 연타 시 첫 번째만 처리됨")
    func confirmButtonExtremeRapidFire20Taps() async throws {
        // Given
        let sut = ReactionInputViewModel()
        var cancellables = Set<AnyCancellable>()
        var triggerCount = 0

        sut.$shouldTriggerSend
            .dropFirst()
            .sink { isTriggered in
                if isTriggered {
                    triggerCount += 1
                    sut.shouldTriggerSend = false
                }
            }
            .store(in: &cancellables)

        // 구독 준비 대기
        try await Task.sleep(nanoseconds: 100_000_000)

        // When: 20번 즉시 연타
        for _ in 0..<20 {
            sut.confirmSendAction()
        }
        try await Task.yield()

        // Then
        try await Task.sleep(nanoseconds: 1_200_000_000)
        
        #expect(triggerCount == 1, "Alert 전송 버튼 초고속 20번 연타해도 첫 번째만 처리되어야 함")
    }

    // MARK: - Full Flow Test

    // 전체 플로우 테스트: Alert 표시(2.0초 쓰로틀링)와 전송(2.0초 쓰로틀링)이 각각 1회만 처리되어야 함
    @Test("BottomButton 탭 후 Alert 전송 버튼 연타 시 각각 스로틀링 적용됨")
    func fullFlowWithBothThrottling() async throws {
        // Given
        let sut = ReactionInputViewModel()
        var cancellables = Set<AnyCancellable>()
        var alertShownCount = 0
        var triggerCount = 0

        sut.$shouldShowConfirmAlert
            .dropFirst()
            .sink { isShown in
                if isShown {
                    alertShownCount += 1
                }
            }
            .store(in: &cancellables)

        sut.$shouldTriggerSend
            .dropFirst()
            .sink { isTriggered in
                if isTriggered {
                    triggerCount += 1
                    sut.shouldTriggerSend = false
                }
            }
            .store(in: &cancellables)

        // 구독 준비 대기
        try await Task.sleep(nanoseconds: 100_000_000)

        // When: BottomButton 3번 즉시 연타
        for _ in 0..<3 {
            sut.sendButtonAction()
        }
        try await Task.yield()

        try await Task.sleep(nanoseconds: 100_000_000)

        // Alert 전송 버튼 3번 즉시 연타
        for _ in 0..<3 {
            sut.confirmSendAction()
        }
        try await Task.yield()

        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Then
        #expect(alertShownCount == 1, "BottomButton 연타 시 Alert는 1번만 표시되어야 함")
        #expect(triggerCount == 1, "Alert 전송 버튼 연타 시 전송은 1번만 트리거되어야 함")
    }
}

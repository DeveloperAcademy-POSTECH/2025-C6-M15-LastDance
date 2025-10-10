//
//  KeyboardManager.swift
//  LastDance
//
//  Created by 신얀 on 10/10/25.
//

import Combine
import SwiftUI

// 환경 변수 키 정의
private struct KeyboardManagerKey: EnvironmentKey {
    static let defaultValue = KeyboardManager()
}

extension EnvironmentValues {
    var keyboardManager: KeyboardManager {
        get { self[KeyboardManagerKey.self] }
        set { self[KeyboardManagerKey.self] = newValue }
    }
}

final class KeyboardManager: ObservableObject {
    @Published private(set) var keyboardHeight: CGFloat = 0

    private var cancellable: AnyCancellable?

    private let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }

    private let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat.zero }

    init() {
        cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide).subscribe(on: DispatchQueue.main)
            .assign(to: \.keyboardHeight, on: self)
    }
}

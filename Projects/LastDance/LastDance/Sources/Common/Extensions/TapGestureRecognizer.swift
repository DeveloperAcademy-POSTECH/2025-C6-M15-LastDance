//
//  TapGestureRecognizer.swift
//  LastDance
//
//  Created by 아우신얀 on 10/21/25.
//

import SwiftUI

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(
            target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

// MARK: - UIApplication + UIGestureRecognizerDelegate

extension UIApplication: UIGestureRecognizerDelegate {
    /// 여러 제스처가 동시에 인식될 수 있는지 결정
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }

    /// 특정 터치를 제스처가 받을지 말지 결정하는 메서드
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch
    ) -> Bool {
        // TextEditor 또는 TextField를 탭할 때는 키보드를 내리지 않음
        if touch.view is UITextView || touch.view is UITextField {
            return false
        }

        var view = touch.view
        while let superview = view?.superview {
            if superview is UITextView || superview is UITextField {
                return false
            }
            view = superview
        }

        return true
    }
}

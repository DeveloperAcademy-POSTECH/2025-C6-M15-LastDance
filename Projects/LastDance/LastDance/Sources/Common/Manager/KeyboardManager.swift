//
//  KeyboardManager.swift
//  LastDance
//
//  Created by 신얀 on 10/10/25.
//

import Combine
import SwiftUI

// MARK: KeyboardInfo
public class KeyboardInfo: ObservableObject {
  public static var shared = KeyboardInfo()

  @Published public var height: CGFloat = 0

  private init() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(self.keyboardChanged),
      name: UIApplication.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(self.keyboardChanged),
      name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(self.keyboardChanged),
      name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }

  @objc func keyboardChanged(notification: Notification) {
    if notification.name == UIApplication.keyboardWillHideNotification {
      self.height = 0
    } else {
      self.height =
        (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
  }
}

// MARK: KeyboardAware
struct KeyboardAware: ViewModifier {
  var minDisntance: CGFloat
  @ObservedObject private var keyboard = KeyboardInfo.shared

  func body(content: Content) -> some View {
    content
      .safeAreaPadding(.bottom, keyboard.height > 0 ? minDisntance : 0)
  }
}

// MARK: View Extension
/// 해당 뷰에서만 사용하는 extension입니다.
extension View {
  public func scrollToMinDistance(minDisntance: CGFloat) -> some View {
    ModifiedContent(content: self, modifier: KeyboardAware(minDisntance: minDisntance))
  }
}

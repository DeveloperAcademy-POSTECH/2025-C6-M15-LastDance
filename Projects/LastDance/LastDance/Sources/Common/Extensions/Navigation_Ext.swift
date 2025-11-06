//
//  Navigation_Ext.swift
//  LastDance
//
//  Created by 배현진 on 11/1/25.
//

import UIKit

/// Custom Navigation 사용으로 인해 사라진 뒤로가기 제스처 사용을 위한 Extension
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

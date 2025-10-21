//
//  Untitled.swift
//  LastDance
//
//  Created by 배현진 on 10/21/25.
//

import SwiftUI

enum LDShadow {
    static let noneShadow = Shadow(
        color: .clear,
        radius: 0,
        positionX: 0,
        positionY: 0)
    static let shadow1 = Shadow(
        color: LDColor.color1.opacity(0.14),
        radius: 8,
        positionX: 0,
        positionY: 0)
    static let shadow2 = Shadow(
        color: LDColor.color1.opacity(0.4),
        radius: 8,
        positionX: 0,
        positionY: 0)
    static let shadow3 = Shadow(
        color: LDColor.color1.opacity(0.25),
        radius: 4,
        positionX: 0,
        positionY: 4)
    
    // MARK: - 뷰에서 정의되어있던 쉐도우 (피그마 x)
    static let shadow4 = Shadow(
        color: .black.opacity(0.1),
        radius: 8,
        positionX: 0,
        positionY: 4)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let positionX: CGFloat
    let positionY: CGFloat
}

//
//  View+Shadow.swift
//  LastDance
//
//  Created by 배현진 on 10/21/25.
//

import SwiftUI

extension View {
    func applyShadow(_ shadow: Shadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.positionX,
            y: shadow.positionY
        )
    }
}

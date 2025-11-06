//
//  BackGround.swift
//  LastDance
//
//  Created by 광로 on 10/20/25.
//

import SwiftUI

struct BackGround: View {
    let geometry: GeometryProxy
    
    var body: some View {
        Image("bauhausArt08")
            .resizable()
            .scaledToFit()
            .frame(width: geometry.size.width, height: geometry.size.height * 2.5)
            .offset(x: 0, y: -160)
            .opacity(0.6)
            .overlay(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: LDColor.color6.opacity(0), location: 0.00),
                        Gradient.Stop(color: LDColor.color6.opacity(0.7), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.456, y: 0.5),
                    endPoint: UnitPoint(x: 0, y: 0.5)
                )
            )
    }
}

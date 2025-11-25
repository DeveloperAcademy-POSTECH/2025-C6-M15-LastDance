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
            .opacity(0.5)
    }
}

//
//  LaunchScreenView.swift
//  LastDance
//
//  Created by 배현진 on 11/18/25.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // 전체 배경 색
            LDColor.color1
                .ignoresSafeArea()

            // 가운데 로고이미지
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 77)
        }
    }
}

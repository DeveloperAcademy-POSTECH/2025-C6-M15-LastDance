//
//  ClipCompleteView.swift
//  LastDance
//
//  Created by 배현진 on 11/11/25.
//

import SwiftUI

struct ClipCompleteView: View {
    @Environment(\.openURL) private var openURL

    private let appStoreURL = URL(string: "https://apps.apple.com/kr/app/%EC%97%AC%EC%9A%B4/id6754415794")!

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Image("envelope")
                .resizable()
                .frame(width: 153, height: 138)

            Spacer().frame(height: 14)

            Text("전송 완료!")
                .font(.system(size: 21, weight: .semibold))
                .lineSpacing(10)

            Spacer().frame(height: 8)

            Text("작가님에게 반응을 보냈어요")
                .foregroundColor(Color(red: 0.31, green: 0.31, blue: 0.31))
                .font(.system(size: 18, weight: .regular))
            
            Spacer()

            ClipBottomButton(text: "전시 계속 보기") {
                openURL(appStoreURL)
            }
                .padding(.bottom, 12)
        }
        .navigationBarBackButtonHidden()
    }
}

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
        ZStack(alignment: .bottom) {
            VStack(alignment: .center) {
                Spacer()
                
                Image("heartenvelope")
                    .resizable()
                    .frame(width: 153, height: 138)
                    .applyShadow(LDShadow.shadow4)
                
                Spacer().frame(height: 14)
                
                Text("전송 완료!")
                    .font(.system(size: 21, weight: .semibold))
                    .lineSpacing(10)
                
                Spacer().frame(height: 8)
                
                Text("작가님에게 반응을 보냈어요")
                    .foregroundColor(Color(red: 0.31, green: 0.31, blue: 0.31))
                    .font(.system(size: 18, weight: .regular))
                
                Spacer(minLength: 120)
            }
            
            VStack(spacing: 10) {
                BubbleView()
                
                BottomButton(text: "전시 계속 보기") {
                    openURL(appStoreURL)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

private struct BubbleView: View {
    var body: some View {
        GeometryReader { geo in
            let total = geo.size.width
            let lane = total / 2.0 - 12
            
            ZStack {
                HStack {
                    FloatingBubble(
                        text: "작가의 반응이 궁금하다면",
                        tailSide: .left,
                        startsDown: true,
                        maxWidth: lane
                    )
                    .padding(.leading, 34)
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()

                    FloatingBubble(
                        text: "방금 쓴 감상을 저장하려면",
                        tailSide: .right,
                        startsDown: false,
                        maxWidth: lane
                    )
                    .padding(.trailing, 34)
                }
            }
        }
        .frame(height: 70)
    }
}

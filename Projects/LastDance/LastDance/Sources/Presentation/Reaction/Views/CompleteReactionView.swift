//
//  CompleteReactionView.swift
//  LastDance
//
//  Created by 신얀 on 10/11/25.
//

import SwiftUI

struct CompleteReactionView: View {
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Image("envelope")
                .resizable()
                .frame(width: 153, height: 138)

            Spacer().frame(height: 14)

            Text("전송 완료!")
                .font(.title2)
                .bold()
                .lineSpacing(10)

            Spacer().frame(height: 8)

            Text("작가에게 반응을 보냈어요")
                .foregroundColor(Color(red: 0.31, green: 0.31, blue: 0.31))

            Spacer()

            HStack(spacing: 19) {
                OutlinedButton(title: "관람 끝내기", color: Color(red: 0.95, green: 0.95, blue: 0.95), textColor: Color(red: 0.39, green: 0.39, blue: 0.39))
                {
                    // TODO: 라우팅 연결 필요 (아카이빙 홈 뷰)
                }

                OutlinedButton(
                    title: "관람 계속하기",
                    color: .black, textColor: .white
                ) {
                    // TODO: 라우팅 연결 필요 (아카이빙뷰)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .navigationBarBackButtonHidden()
    }
}

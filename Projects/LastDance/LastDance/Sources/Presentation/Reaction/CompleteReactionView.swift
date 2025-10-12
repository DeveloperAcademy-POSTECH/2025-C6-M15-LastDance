//
//  CompleteReactionView.swift
//  LastDance
//
//  Created by 신얀 on 10/11/25.
//

import SwiftUI

struct CompleteReactionView: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 94, height: 94)
                .foregroundStyle(.gray)
                .padding()

            Text("전송 완료!")
                .font(.title2)
                .bold()

            Spacer().frame(height: 12)

            Text("작가에게 반응을 보냈어요")

            Spacer().frame(height: 197)

            HStack {
                OutlinedButton(title: "관람 끝내기") {
                    // TODO: 관람 끝내기 네비게이션 연결
                }
                
                Spacer()
                
                OutlinedButton(title: "관람 계속하기") {
                    // TODO: 관람 계속하기 네비게이션 연결
                }
            }
            .padding(.horizontal, 33)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    CompleteReactionView()
}

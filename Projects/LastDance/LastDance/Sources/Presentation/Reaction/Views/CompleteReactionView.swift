//
//  CompleteReactionView.swift
//  LastDance
//
//  Created by 신얀 on 10/11/25.
//

import SwiftUI

struct CompleteReactionView: View {
    @EnvironmentObject private var router: NavigationRouter

    let exhibitionId: Int

    init(exhibitionId: Int) {
        self.exhibitionId = exhibitionId
        // 반응 전송이 완료되면 사용한 이미지 URL을 UserDefaults에서 삭제
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.uploadedImageUrl.key)
    }

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            Image("envelope")
                .resizable()
                .frame(width: 153, height: 138)

            Spacer().frame(height: 14)

            Text("전송 완료!")
                .font(LDFont.heading03)
                .lineSpacing(10)

            Spacer().frame(height: 8)

            Text("작가에게 반응을 보냈어요")
                .foregroundColor(LDColor.gray4)
                .font(LDFont.regular01)

            Spacer()

            HStack(spacing: 19) {
                OutlinedButton(title: "관람 끝내기", color: LDColor.gray3, textColor: LDColor.gray1) {
                    router.push(.audienceArchiving)
                }

                OutlinedButton(
                    title: "관람 계속하기",
                    color: LDColor.color1, textColor: LDColor.color6
                ) {
                    Log.debug(
                        "CompleteReactionView: Tapping Continue Viewing. Popping to archive with exhibitionId: \(exhibitionId)"
                    )
                    router.popTo(.archive(id: exhibitionId))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .navigationBarBackButtonHidden()
    }
}

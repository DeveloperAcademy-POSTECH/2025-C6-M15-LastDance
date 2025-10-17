//
//  OnboardingView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        VStack {
            Text("OnboardingView - API 테스트")
                .padding()

            Button("InputArtworkInfoView 테스트") {
                // 임시 이미지 생성
                let tempImage = UIImage(systemName: "photo") ?? UIImage()

                // exhibition_id를 1로 설정해서 테스트
                router.push(.inputArtworkInfo(
                    image: tempImage,
                    exhibitionId: 1,
                    artistId: nil
                ))
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

#Preview {
    OnboardingView()
}

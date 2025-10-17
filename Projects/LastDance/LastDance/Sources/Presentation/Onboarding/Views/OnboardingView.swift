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
        VStack(spacing: 20) {
            Text("Onboarding View")
                .font(.largeTitle)

            // 테스트용: 반응 생성 버튼
            Button("테스트 반응 생성 (전시 ID: 1)") {
                createTestReaction()
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button(action: {
                router.push(.exhibitionArchive(exhibitionId: 1))
            }, label: {
                Text("ExhibitionArchiveView")
            })
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }

    // 테스트용 반응 생성 함수
    private func createTestReaction() {
        let reactionService = ReactionAPIService()

        // 임시 데이터 - 실제 값으로 교체 필요
        let dto = ReactionRequestDto(
            artworkId: 1,      // 전시 ID 1의 작품 ID (실제 값 확인 필요)
            visitorId: 1,      // 임시 visitor ID
            visitId: 1,        // 임시 visit ID
            comment: "테스트 반응입니다",
            imageUrl: nil,
            tagIds: [1]        // 임시 tag ID
        )

        reactionService.createReaction(dto: dto) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    Log.debug("[OnboardingView] 반응 생성 성공: \(response)")
                case .failure(let error):
                    Log.error("[OnboardingView] 반응 생성 실패: \(error)")
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}

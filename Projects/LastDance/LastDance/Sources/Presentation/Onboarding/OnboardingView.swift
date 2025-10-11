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
            Text("OnboardingView")
            
            // 뷰 테스트 해보기 위한 임시 코드
             Button(action: {
                 router.push(.category)
             }, label: {
                 Text("CategoryView")
             })
            
            Button(action: {
                router.push(.completeReaction)
            }, label: {
                Text("CompleteReactionView")
            })
        }
        .onAppear {
            Log.debug("디버깅")
        }
    }
}

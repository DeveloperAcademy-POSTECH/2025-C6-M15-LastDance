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
            Text("Onboarding View")
                .font(.largeTitle)

            Button("전시 아카이브 테스트") {
                router.push(.exhibitionArchive(exhibitionId: 1))
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}


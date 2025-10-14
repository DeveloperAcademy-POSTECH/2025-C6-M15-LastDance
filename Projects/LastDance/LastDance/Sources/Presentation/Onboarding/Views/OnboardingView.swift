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
            Button(action: {
                router.push(.identitySelection)
            }) {
                Text("IdentitySelectionView")
                    .foregroundStyle(.blue)
            }

            Button(action: {
                router.push(.audienceArchiving)
            }) {
                Text("AudienceArchivingView")
                    .foregroundStyle(.blue)
            }

            Button(action: {
                router.push(.articleArchiving)
            }) {
                Text("ArticleArchivingView")
                    .foregroundStyle(.blue)
            }

            Button(action: {
                router.push(.exhibitionList)
            }) {
                Text("ExhibitionListView")
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    OnboardingView()
}

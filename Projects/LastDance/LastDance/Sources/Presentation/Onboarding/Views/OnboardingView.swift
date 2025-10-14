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

            NavigationLink(destination: IdentitySelectionView()) {
                Text("IdentitySelectionView")
                    .foregroundStyle(.blue)
            }

            NavigationLink(destination: AudienceArchivingView()) {
                Text("AudienceArchivingView")
                    .foregroundStyle(.blue)
            }
            NavigationLink(destination: ArticleArchivingView()) {
                Text("ArticleArchivingView")
                    .foregroundStyle(.blue)
            }

            NavigationLink(destination: ExhibitionListView()) {
                Text("ExhibitionListView")
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    OnboardingView()
}

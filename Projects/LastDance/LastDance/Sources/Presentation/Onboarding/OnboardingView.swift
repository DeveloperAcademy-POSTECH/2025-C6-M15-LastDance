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
                router.push(.articleExhibitionList)
            }) {
                Text("ArticleExhibitionListView")
                    .foregroundStyle(.blue)
            }

            Button(action: {
                router.push(.articleList(selectedExhibitionId: "exhibition_light"))
            }) {
                Text("ArticleListView")
                    .foregroundStyle(.blue)
            }

            Button(action: {
                router.push(.completeArticleList(selectedExhibitionId: "exhibition_light", selectedArtistId: "artist_kimjiin"))
            }) {
                Text("CompleteArticleListView")
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


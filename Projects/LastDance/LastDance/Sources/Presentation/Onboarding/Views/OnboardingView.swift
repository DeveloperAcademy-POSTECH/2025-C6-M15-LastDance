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
//            Text("OnboardingView")
            Button(action: {
                router.push(.exhibitionArchive(exhibitionId: 1))
            }, label: {
                Text("ExhibitionArchiveView")
            })
        }
    }
}

#Preview {
    OnboardingView()
}

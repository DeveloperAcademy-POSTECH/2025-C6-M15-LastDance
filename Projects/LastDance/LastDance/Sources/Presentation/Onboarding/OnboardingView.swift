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
            
            Button(action: {
                router.push(.artworkDetail(id: "artwork_light_01"))
            }, label: {
                Text("ArtworkDetailView로 이동")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            })

        }
    }
}

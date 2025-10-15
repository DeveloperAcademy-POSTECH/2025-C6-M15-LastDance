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
                router.push(.camera)
            }, label: {
                Text("camera")
            })
        }
    }
}

#Preview {
    OnboardingView()
}

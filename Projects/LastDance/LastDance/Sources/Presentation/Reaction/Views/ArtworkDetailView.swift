//
//  ArtworkDetailView.swift
//  LastDance
//
//  Created by 신얀 on 10/10/25.
//

import SwiftData
import SwiftUI

struct ArtworkDetailView: View {
    @Environment(\.keyboardManager) var keyboardManager
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ReactionInputViewModel()

    let artworkId: String

    init(artworkId: String) {
        self.artworkId = artworkId
    }

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ArtworkInfoView(artworkId: artworkId)
                        .offset(y: -120)
                        .ignoresSafeArea(.container, edges: .top)
                        .padding(.bottom, -120)

                    Spacer().frame(height: 26)

                    ReactionFormView(artworkId: artworkId, viewModel: viewModel)

                    Spacer()
                }
                .padding(.bottom, keyboardManager.keyboardHeight)
            }

            BottomButton(
                text: "전송하기",
                isEnabled: !viewModel.isSendButtonDisabled,
                action: {
                    Log.debug("- [ArtworkDetailView] artworkId: \(artworkId)")
                    Log.debug("- [ArtworkDetailView] selectedCategories: \(Array(viewModel.selectedCategories))")
                    Log.debug("- [ArtworkDetailView] message: \(viewModel.message)")

                    viewModel.saveReaction(artworkId: artworkId) { success in
                        if success {
                            // 저장 완료시 다음 화면으로 이동하도록 구현
                            Log.debug("[ArtworkDetailView] 저장 성공, 화면 이동")
                            router.push(.completeReaction)
                        } else {
                            Log.debug("[ArtworkDetailView] 저장 실패")
                        }
                    }
                }
            )
        }
        .onAppear {
            if let savedCategories = UserDefaults.standard.stringArray(forKey: .selectedCategories) {
                viewModel.selectedCategories = Set(savedCategories)
            }
            Log.debug("[ArtworkDetailView]: \(viewModel.selectedCategories)")
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .navigationBarTitle("반응 남기기", displayMode: .inline)
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("반응 남기기")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .animation(
            .easeOut(duration: 0.25),
            value: keyboardManager.keyboardHeight
        )
    }
}

#Preview {
    ArtworkDetailView(artworkId: "artwork_light_01")
}

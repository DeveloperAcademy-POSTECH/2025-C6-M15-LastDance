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
    @Environment(\.modelContext) private var context
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
                    
                    ReactionFormView(artworkId: artworkId)

                    Spacer()
                }
                .padding(.bottom, keyboardManager.keyboardHeight)
            }

            BottomButton(
                text: "전송하기",
                isEnabled: !viewModel.isSendButtonDisabled,
                action: {
                    viewModel.saveReaction(artworkId: artworkId, context: context)
                }
            )
        }
        .onAppear {
            if let savedCategories = UserDefaults.standard.array(forKey: "selectedCategories") as? [String] {
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

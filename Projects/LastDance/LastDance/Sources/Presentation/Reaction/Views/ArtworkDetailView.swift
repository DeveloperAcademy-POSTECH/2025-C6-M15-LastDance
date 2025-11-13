//
//  ArtworkDetailView.swift
//  LastDance
//
//  Created by 신얀 on 10/10/25.
//

import SwiftData
import SwiftUI

struct ArtworkDetailView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var router: NavigationRouter
    @EnvironmentObject private var viewModel: ReactionInputViewModel

    let artworkId: Int
    let capturedImage: UIImage?
    let exhibitionId: Int?

    init(artworkId: Int, capturedImage: UIImage? = nil, exhibitionId: Int) {
        self.artworkId = artworkId
        self.capturedImage = capturedImage
        self.exhibitionId = exhibitionId

        // 카테고리 초기화
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.selectedCategories.rawValue)
    }

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ArtworkInfoView(artworkId: artworkId, capturedImage: capturedImage)
                        .offset(y: -120)
                        .ignoresSafeArea(.container, edges: .top)
                        .padding(.bottom, -120)

                    Spacer().frame(height: 28)

                    ReactionFormView(artworkId: artworkId)

                    Spacer()
                }
            }
            .scrollDismissesKeyboard(.never)
            .scrollToMinDistance(minDisntance: 32)

            BottomButton(
                text: "전송하기",
                isEnabled: !viewModel.isSendButtonDisabled,
                action: {
                    viewModel.sendButtonAction()
                }
            )
        }
        .background(LDColor.color5)
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    viewModel.selectedCategories = []
                    viewModel.selectedCategoryIds = []
                    viewModel.selectedTagIds = []
                    viewModel.selectedTagsName = []
                    router.popLast()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("반응 남기기")
                    .font(LDFont.heading04)
                    .foregroundColor(LDColor.color6)
            }
        }
        .environmentObject(viewModel)
        .onChange(of: viewModel.shouldTriggerSend) { _, shouldTrigger in
            if shouldTrigger {
                viewModel.performSendReaction(artworkId: artworkId, exhibitionId: exhibitionId) {
                    success, exhibitionId in
                    if success, let exhibitionId = exhibitionId {
                        router.push(.completeReaction(exhibitionId: exhibitionId))
                    }
                }
                viewModel.shouldTriggerSend = false
            }
        }
        .customAlert(
            isPresented: $viewModel.shouldShowConfirmAlert,
            image: viewModel.alertType.image,
            title: viewModel.alertType.title,
            message: viewModel.alertType.message,
            buttonText: viewModel.alertType.buttonText,
            action: {
                if viewModel.alertType == .confirmation {
                    viewModel.confirmSendAction()
                } else {
                    viewModel.shouldShowConfirmAlert = false
                }
            },
            cancelAction: {
                viewModel.shouldShowConfirmAlert = false
            }
        )
    }
}

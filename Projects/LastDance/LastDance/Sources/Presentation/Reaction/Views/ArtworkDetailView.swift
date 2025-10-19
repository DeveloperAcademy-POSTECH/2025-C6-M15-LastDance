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

    private let apiService = ReactionAPIService()

    let artworkId: Int
    let capturedImage: UIImage?

    @State private var showAlert = false

    init(artworkId: Int, capturedImage: UIImage? = nil) {
        self.artworkId = artworkId
        self.capturedImage = capturedImage

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
                .padding(.bottom, keyboardManager.keyboardHeight)
            }

            BottomButton(
                text: "전송하기",
                isEnabled: !viewModel.isSendButtonDisabled,
                action: {
                    showAlert = true

//                    Log.debug("artworkId: \(artworkId)")
//                    Log.debug("selectedCategories: \(Array(viewModel.selectedCategories))")
//                    Log.debug("message: \(viewModel.message)")
//
//                    // TODO: 실제 값으로 교체 필요
//                    let visitorId = 1  // 실제 visitor ID로 교체
//                    let visitId = 1    // 실제 visit ID로 교체
//                    let imageUrl: String? = nil  // 이미지 URL이 있으면 전달
//                    // 테스트를 위해 임시 tagIds 설정 (실제로는 선택된 카테고리를 태그 ID로 변환 필요)
//                    let tagIds: [Int] = [1, 2, 3]
//
//                    viewModel.saveReaction(
//                        artworkId: artworkId,
//                        visitorId: visitorId,
//                        visitId: visitId,
//                        imageUrl: imageUrl,
//                        tagIds: tagIds
//                    ) { success in
//                        if success {
//                            Log.debug("저장 성공, 화면 이동")
//                            router.push(.completeReaction)
//                        } else {
//                            Log.debug("저장 실패")
//                        }
//                    }
                }
            )
        }
        .onAppear {
            Log.debug("선택된 카테고리: \(viewModel.selectedCategories)")
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
        .environmentObject(viewModel)
        .customAlert(isPresented: $showAlert, image: "message", title: "메시지를 전송하시겠어요?", message: "작가님에게 반응이 전달돼요.", buttonText: "전송하기", action: {
            showAlert = false
        })
    }
}

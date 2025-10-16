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

    private let apiService = ReactionAPIService()

    let artworkId: Int

    init(artworkId: Int) {
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

                    // 테스트 버튼
                    Button(action: {
                        viewModel.getDetailReactionAPI(reactionId: 1)
                    }) {
                        Text("반응 상세 조회 API 테스트 (reactionId: 1)")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .padding()

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

                    // TODO: 실제 값으로 교체 필요
                    let visitorId = 1  // 실제 visitor ID로 교체
                    let visitId = 1    // 실제 visit ID로 교체
                    let imageUrl: String? = nil  // 이미지 URL이 있으면 전달
                    // 테스트를 위해 임시 tagIds 설정 (실제로는 선택된 카테고리를 태그 ID로 변환 필요)
                    let tagIds: [Int] = [1, 2, 3]

                    viewModel.saveReaction(
                        artworkId: artworkId,
                        visitorId: visitorId,
                        visitId: visitId,
                        imageUrl: imageUrl,
                        tagIds: tagIds
                    ) { success in
                        if success {
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

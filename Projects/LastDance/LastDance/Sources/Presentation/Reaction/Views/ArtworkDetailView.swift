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

                    Spacer()
                }
                .padding(.bottom, keyboardManager.keyboardHeight)
            }

            BottomButton(
                text: "전송하기",
                isEnabled: !viewModel.isSendButtonDisabled,
                action: {
                    Log.debug("artworkId: \(artworkId)")
                    Log.debug("selectedCategories: \(Array(viewModel.selectedCategories))")
                    Log.debug("message: \(viewModel.message)")

                    // UserDefaults에서 저장된 visitorUUID 가져오기
                    guard let visitorUUID = UserDefaults.standard.string(forKey: UserDefaultsKey.visitorUUID.rawValue) else {
                        Log.error("visitorUUID를 찾을 수 없습니다")
                        return
                    }

                    // SwiftData에서 UUID로 Visitor 조회
                    let visitors = SwiftDataManager.shared.fetchAll(Visitor.self)
                    guard let visitor = visitors.first(where: { $0.uuid == visitorUUID }) else {
                        Log.error("Visitor를 찾을 수 없습니다")
                        return
                    }

                    // SwiftData에서 해당 Visitor의 VisitHistory 조회
                    let visitHistories = SwiftDataManager.shared.fetchAll(VisitHistory.self)
                    guard let visitHistory = visitHistories.first(where: { $0.visitorId == visitor.id }) else {
                        Log.error("VisitHistory를 찾을 수 없습니다")
                        return
                    }

                    let visitorId = visitor.id
                    let visitId = visitHistory.id
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
                            Log.debug("저장 성공, 화면 이동")
                            router.push(.completeReaction)
                        } else {
                            Log.debug("저장 실패")
                        }
                    }
                }
            )
        }
        .onAppear {
            if let savedCategories = UserDefaults.standard.stringArray(forKey: .selectedCategories) {
                viewModel.selectedCategories = Set(savedCategories)
            }
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
    }
}

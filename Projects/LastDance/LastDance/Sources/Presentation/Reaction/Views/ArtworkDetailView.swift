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
    @EnvironmentObject private var viewModel: ReactionInputViewModel

    private let apiService = ReactionAPIService()

    let artworkId: Int
    let capturedImage: UIImage?

    @State private var showAlert = false
    @State private var alertType: AlertType = .confirmation
    @State private var exhibitionId: String = ""

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
                    alertType = .confirmation
                    showAlert = true
                }
            )
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("반응 남기기")
                    .font(.headline)
                    .foregroundColor(LDColor.color6)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .animation(
            .easeOut(duration: 0.25),
            value: keyboardManager.keyboardHeight
        )
        .environmentObject(viewModel)
        .customAlert(
            isPresented: $showAlert,
            image: alertType == .confirmation ? "message" : "warning",
            title: alertType == .confirmation ? "메시지를 전송하시겠어요?" : "아쉬워요!",
            message: alertType == .confirmation ? "작가님에게 반응이 전달돼요." : "메시지 전송에 실패했어요.",
            buttonText: alertType == .confirmation ? "전송하기" : "다시 보내기",
            action: {
                if alertType == .confirmation {
                    Log.debug("artworkId: \(artworkId)")
                    Log.debug("selectedCategories: \(Array(viewModel.selectedCategories))")
                    Log.debug("message: \(viewModel.message)")

                    // UserDefaults에서 업로드된 이미지 URL 가져오기
                    let imageUrl = UserDefaults.standard.string(forKey: UserDefaultsKey.uploadedImageUrl.key)
                    
                    // UserDefaults에서 저장된 visitorUUID 가져오기
                    guard let visitorUUID = UserDefaults.standard.string(forKey: UserDefaultsKey.visitorUUID.rawValue) else {
                        Log.warning("visitorUUID를 찾을 수 없습니다")
                        return
                    }

                    // SwiftData에서 UUID로 Visitor 조회
                    let visitors = SwiftDataManager.shared.fetchAll(Visitor.self)
                    guard let visitor = visitors.first(where: { $0.uuid == visitorUUID }) else {
                        Log.warning("Visitor를 찾을 수 없습니다")
                        return
                    }

                    // SwiftData에서 해당 Visitor의 VisitHistory 조회
                    let visitHistories = SwiftDataManager.shared.fetchAll(VisitHistory.self)
                    guard let visitHistory = visitHistories.first(where: { $0.visitorId == visitor.id }) else {
                        Log.warning("VisitHistory를 찾을 수 없습니다")
                        return
                    }

                    let visitorId = visitor.id
                    let visitId = visitHistory.id
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
                            showAlert = false
                            router.push(.completeReaction)
                        } else {
                            Log.debug("저장 실패")
                            alertType = .error
                        }
                    }
                } else {
                    showAlert = false
                }
            }
        )
    }
}

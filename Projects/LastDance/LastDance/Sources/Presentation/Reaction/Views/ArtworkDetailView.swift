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

    private let apiService = ReactionAPIService()

    let artworkId: Int
    let capturedImage: UIImage?
    let exhibitionId: Int?

    @State private var showAlert = false
    @State private var alertType: AlertType = .confirmation

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
                    alertType = .confirmation
                    showAlert = true
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
                        alertType = .error
                        showAlert = true
                        return
                    }

                    // 현재 작품이 속한 전시 ID 찾기
                    let artworks = SwiftDataManager.shared.fetchAll(Artwork.self)
                    guard let currentArtwork = artworks.first(where: { $0.id == artworkId }) else {
                        Log.warning("현재 Artwork을 찾을 수 없습니다. (exhibitionId 파악 불가)")
                        alertType = .error
                        showAlert = true
                        return
                    }
                    let currentExhibitionId = currentArtwork.exhibitionId

                    // UserDefaults에서 visitId 가져오기
                    guard let visitId = UserDefaults.standard.object(
                        forKey: UserDefaultsKey.visitId.key
                    ) as? Int else {
                        Log.warning("visitId를 UserDefaults에서 찾을 수 없습니다.")
                        alertType = .error
                        showAlert = true
                        return
                    }

                    let visitorId = visitor.id
                    let tagIds = Array(viewModel.selectedTagIds)

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
                            router.push(.completeReaction(exhibitionId: exhibitionId ?? 1))
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

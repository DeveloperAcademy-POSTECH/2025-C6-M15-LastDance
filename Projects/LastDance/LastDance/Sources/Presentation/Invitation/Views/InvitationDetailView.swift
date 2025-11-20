//
//  InvitationDetailView.swift
//  LastDance
//
//  Created by donghee on 11/17/25.
//

import SwiftUI

struct InvitationDetailView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel: InvitationDetailViewModel
    @FocusState private var isTextFieldFocused: Bool
    @GestureState private var dragOffset: CGFloat = 0

    init(exhibition: Exhibition) {
        _viewModel = StateObject(wrappedValue: InvitationDetailViewModel(exhibition: exhibition))
    }

    private func handleBackNavigation() {
        if !viewModel.invitationMessage.isEmpty {
            viewModel.showDeleteAlert = true
        } else {
            router.popLast()
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 스크롤 가능한 콘텐츠
            ScrollView {
                VStack(spacing: 0) {
                    // 전시 카드
                    ExhibitionInvitationCard(
                        exhibition: viewModel.exhibition,
                        invitationMessage: viewModel.invitationMessage,
                        artistName: viewModel.artistName
                    )
                    .padding(.top, 24)

                    Spacer()
                        .frame(height: 32)

                    // 전시 정보
                    InvitationExhibitionInfo(
                        exhibition: viewModel.exhibition,
                        invitationMessage: viewModel.invitationMessage,
                        onWriteMessage: {
                            viewModel.isTextInputSheetPresented = true
                        },
                        artistName: viewModel.artistName,
                        venueName: viewModel.venueName
                    )
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 100)
                }
            }
            .background(LDColor.color6)

            // 초대하기 버튼 (하단 고정 - 키보드 영향 안받음)
            VStack(spacing: 0) {
                BottomButton(text: "초대하기") {
                    viewModel.handleShare()
                }
            }
            .background(LDColor.color6)

            // 텍스트 입력 오버레이
            if viewModel.isTextInputSheetPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.isTextInputSheetPresented = false
                        isTextFieldFocused = false
                    }

                VStack(spacing: 0) {
                    Spacer()

                    // 중앙에 텍스트만 표시 (가운데 정렬)
                    HStack(spacing: 0) {
                        Text(viewModel.invitationMessage.isEmpty ? "" : viewModel.invitationMessage)
                            .font(LDFont.medium04)
                            .foregroundColor(.white)

                        // 커서 효과 (깜빡이는 |)
                        if viewModel.invitationMessage.isEmpty || isTextFieldFocused {
                            Text("|")
                                .font(LDFont.medium04)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // 글자 수 표시 (하단)
                    Text("\(viewModel.characterCount)/20")
                        .font(LDFont.medium05)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 16)

                    Spacer()
                }

                // 투명한 TextField (키보드만 올리기 위함)
                TextField("", text: $viewModel.invitationMessage)
                    .opacity(0)
                    .frame(width: 0, height: 0)
                    .focused($isTextFieldFocused)
                    .onChange(of: viewModel.invitationMessage) { newValue in
                        if newValue.count > 20 {
                            viewModel.invitationMessage = String(newValue.prefix(20))
                        }
                    }
                    .onSubmit {
                        viewModel.isTextInputSheetPresented = false
                        isTextFieldFocused = false
                    }
            }
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    handleBackNavigation()
                }
            }

            ToolbarItem(placement: .principal) {
                Text("전시 초대하기")
                    .font(LDFont.heading04)
                    .foregroundColor(LDColor.color1)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    // 오른쪽으로 드래그할 때만 처리
                    if value.translation.width > 0 {
                        state = value.translation.width
                    }
                }
                .onEnded { value in
                    // 충분히 드래그했을 때 (50 이상)
                    if value.translation.width > 50 {
                        handleBackNavigation()
                    }
                }
        )
        .customAlert(
            isPresented: $viewModel.showDeleteAlert,
            image: "warning",
            title: "작업 내용을 잃게 돼요",
            message: "",
            buttonText: "나가기",
            action: {
                router.popLast()
            },
            cancelAction: {
                viewModel.showDeleteAlert = false
            }
        )
        .onAppear {
            viewModel.isTextInputSheetPresented = false
        }
        .onChange(of: viewModel.isTextInputSheetPresented) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            // 공유 시트 dismiss 후 CreateInvitationView로 이동
            router.removeAll()
            router.push(.createInvitation)
        } content: {
            ShareSheet(items: [viewModel.getShareMessage()])
        }
    }
}
// MARK: - ExhibitionInvitationCard

private struct ExhibitionInvitationCard: View {
    let exhibition: Exhibition
    let invitationMessage: String
    let artistName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 배경 이미지
            if let coverImageURLString = exhibition.coverImageName {
                CachedImage(coverImageURLString)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 281, height: 381)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 281, height: 381)
            }

            // 그라데이션 오버레이
            LinearGradient(
                stops: [
                    Gradient.Stop(color: .black.opacity(0), location: 0.00),
                    Gradient.Stop(color: .black, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0.24),
                endPoint: UnitPoint(x: 0.5, y: 1)
            )
            .frame(width: 281, height: 190)

            // 텍스트 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(exhibition.title)
                    .font(LDFont.heading06)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Text(artistName)
                    .font(LDFont.medium05)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.bottom, 14)

                Text(invitationMessage.isEmpty ? "초대 내용 작성 ..." : invitationMessage)
                    .font(LDFont.medium05)
                    .foregroundColor(invitationMessage.isEmpty ? .white.opacity(0.6) : .white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .frame(width: 281, height: 381)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 0)
    }
}

// MARK: - InvitationExhibitionInfo

private struct InvitationExhibitionInfo: View {
    let exhibition: Exhibition
    let invitationMessage: String
    let onWriteMessage: () -> Void
    let artistName: String
    let venueName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(exhibition.title)
                .font(LDFont.heading06)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .topLeading)

            Text(artistName)
                .font(LDFont.medium05)
                .foregroundColor(LDColor.color2)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.top, 8)

            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundColor(LDColor.color1)

                Text(
                    Date.formatShortDateRange(start: exhibition.startDate, end: exhibition.endDate)
                )
                .font(LDFont.medium04)
                .foregroundColor(LDColor.color1)
            }
            .padding(.top, 12)

            HStack(spacing: 8) {
                Image(systemName: "mappin")
                    .font(.system(size: 16))
                    .foregroundColor(LDColor.color1)

                Text(venueName)
                    .font(LDFont.medium04)
                    .foregroundColor(LDColor.color1)
            }
            .padding(.top, 8)

            // 초대 내용이 비어있으면 작성 버튼, 있으면 작성한 내용 표시
            if invitationMessage.isEmpty {
                Button(action: onWriteMessage) {
                    HStack(spacing: 4) {
                        Text("초대 내용 작성하기")
                            .font(LDFont.heading06)
                            .foregroundColor(.black)

                        Image(systemName: "pencil.line")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 20)
            } else {
                Button(action: onWriteMessage) {
                    Text(invitationMessage)
                        .font(LDFont.medium04)
                        .foregroundColor(LDColor.color1)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .padding(.top, 24)
            }
        }
    }
}

#Preview {
    InvitationDetailView(
        exhibition: Exhibition(
            id: 1,
            title: "조셀조이 : 기억의 지층, 경계를 넘는 시선",
            startDate: "2025-08-16",
            endDate: "2025-10-12"
        )
    )
    .environmentObject(NavigationRouter())
}

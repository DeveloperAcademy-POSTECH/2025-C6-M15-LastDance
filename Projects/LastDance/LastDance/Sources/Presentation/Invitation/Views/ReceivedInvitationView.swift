//
//  ReceivedInvitationView.swift
//  LastDance
//
//  Created by donghee on 11/19/25.
//

import SwiftUI

struct ReceivedInvitationView: View {
    let invitationCode: String
    @StateObject private var viewModel: ReceivedInvitationViewModel
    @EnvironmentObject private var router: NavigationRouter
    @State private var showConfirmAlert: Bool = false

    init(invitationCode: String) {
        self.invitationCode = invitationCode
        _viewModel = StateObject(
            wrappedValue: ReceivedInvitationViewModel(invitationCode: invitationCode))
    }

    var body: some View {
        ZStack {
            LDColor.color6.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .tint(LDColor.color1)
            } else if let invitation = viewModel.invitation {
                VStack(spacing: 0) {
                    // 타이틀
                    Text("전시 초대장")
                        .font(LDFont.heading03)
                        .foregroundColor(LDColor.color1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)

                    // 초대장 카드
                    InvitationCard(invitation: invitation)
                        .padding(.horizontal, 16)

                    // 전시 정보
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(invitation.exhibitionTitle)
                                .font(LDFont.heading03)
                                .foregroundColor(LDColor.color1)

                            Text(invitation.artistName)
                                .font(LDFont.medium04)
                                .foregroundColor(LDColor.color2)
                                .padding(.bottom, 8)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14))
                                Text(
                                    Date.formatShortDateRange(
                                        start: invitation.startDate, end: invitation.endDate)
                                )
                                .font(LDFont.medium04)
                            }
                            .foregroundColor(LDColor.color2)

                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 14))
                                Text("\(invitation.venueName) \(invitation.venueAddress)")
                                    .font(LDFont.medium04)
                            }
                            .foregroundColor(LDColor.color2)
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    Spacer()

                    // 갈게요 버튼
                    Button(action: {
                        showConfirmAlert = true
                    }) {
                        if viewModel.isProcessingInterest {
                            ProgressView()
                                .tint(LDColor.color6)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        } else {
                            Text("갈게요")
                                .font(LDFont.heading03)
                                .foregroundColor(LDColor.color6)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        }
                    }
                    .background(LDColor.color1)
                    .cornerRadius(8)
                    .disabled(viewModel.isProcessingInterest)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 34)
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text("⚠️")
                        .font(.system(size: 50))

                    Text(errorMessage)
                        .font(LDFont.medium04)
                        .foregroundColor(LDColor.color2)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert("전시에 참여하시겠어요?", isPresented: $showConfirmAlert) {
            Button("아니요", role: .cancel) {}
            Button("네") {
                viewModel.handleGoToExhibition { success in
                    if success {
                        Log.debug(
                            "전시 보러가기 - exhibitionId: \(viewModel.invitation?.exhibitionId ?? 0)")
                        // TODO: 전시 상세 화면으로 네비게이션
                        // router.push(.exhibitionDetail(id: invitation.exhibitionId))
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadInvitation()
        }
    }
}

// MARK: - Invitation Card

private struct InvitationCard: View {
    let invitation: Invitation

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // 배경 이미지
                CachedImage(
                    invitation.coverImageName,
                    targetSize: CGSize(width: geometry.size.width, height: 460)
                )
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: 460)
                .clipped()

                // 그라데이션 오버레이
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.6),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // 텍스트 오버레이
                VStack(alignment: .leading, spacing: 4) {
                    Text(invitation.exhibitionTitle)
                        .font(LDFont.heading02)
                        .foregroundColor(.white)

                    Text(invitation.artistName)
                        .font(LDFont.medium04)
                        .foregroundColor(.white.opacity(0.9))

                    if !invitation.invitationMessage.isEmpty {
                        Text(invitation.invitationMessage)
                            .font(LDFont.medium04)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 8)
                            .padding(.bottom, 12)

                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: 460)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

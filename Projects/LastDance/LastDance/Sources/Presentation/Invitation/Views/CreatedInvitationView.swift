//
//  CreatedInvitationView.swift
//  LastDance
//
//  Created by donghee on 11/18/25.
//

import SwiftUI

/// 이미 생성된 초대장을 조회/공유/삭제하는 화면
struct CreatedInvitationView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel: InvitationShareViewModel

    init(invitation: Invitation) {
        _viewModel = StateObject(wrappedValue: InvitationShareViewModel(invitation: invitation))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 스크롤 가능한 콘텐츠
            ScrollView {
                VStack(spacing: 0) {
                    // 전시 카드
                    ExhibitionInvitationCard(
                        invitation: viewModel.invitation
                    )
                    .padding(.top, 24)

                    Spacer()
                        .frame(height: 32)

                    // 전시 정보
                    InvitationExhibitionInfo(
                        invitation: viewModel.invitation
                    )
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 100)
                }
            }
            .background(LDColor.color6)

            // 초대하기 버튼 (하단 고정)
            VStack(spacing: 0) {
                BottomButton(text: "초대하기") {
                    viewModel.handleShare()
                }
            }
            .background(LDColor.color6)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    router.popLast()
                }
            }

            ToolbarItem(placement: .principal) {
                Text("전시 초대하기")
                    .font(LDFont.heading04)
                    .foregroundColor(LDColor.color1)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.handleDelete()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                        .foregroundColor(LDColor.color1)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .customAlert(
            isPresented: $viewModel.showDeleteAlert,
            image: "",
            title: "초대장을 삭제하시겠어요?",
            message: nil,
            buttonText: "확인",
            action: {
                viewModel.confirmDelete { success in
                    if success {
                        router.popLast()
                    }
                }
            },
            cancelAction: {
                viewModel.showDeleteAlert = false
            }
        )
        .sheet(isPresented: $viewModel.showShareSheet) {
            ShareSheet(items: [viewModel.shareMessage ?? ""])
        }
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - ExhibitionInvitationCard

private struct ExhibitionInvitationCard: View {
    let invitation: Invitation

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 배경 이미지
            if let coverImageURLString = invitation.coverImageName {
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
                Text(invitation.exhibitionTitle)
                    .font(LDFont.heading06)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Text(invitation.artistName)
                    .font(LDFont.medium05)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.bottom, 14)

                if !invitation.invitationMessage.isEmpty {
                    Text(invitation.invitationMessage)
                        .font(LDFont.medium05)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
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
    let invitation: Invitation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(invitation.exhibitionTitle)
                .font(LDFont.heading06)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .topLeading)

            Text(invitation.artistName)
                .font(LDFont.medium05)
                .foregroundColor(LDColor.color2)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.top, 8)

            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundColor(LDColor.color1)

                Text(
                    Date.formatShortDateRange(start: invitation.startDate, end: invitation.endDate)
                )
                .font(LDFont.medium04)
                .foregroundColor(LDColor.color1)
            }
            .padding(.top, 12)

            HStack(spacing: 8) {
                Image(systemName: "mappin")
                    .font(.system(size: 16))
                    .foregroundColor(LDColor.color1)

                Text("\(invitation.venueName) \(invitation.venueAddress)")
                    .font(LDFont.medium04)
                    .foregroundColor(LDColor.color1)
            }
            .padding(.top, 8)
        }
    }
}

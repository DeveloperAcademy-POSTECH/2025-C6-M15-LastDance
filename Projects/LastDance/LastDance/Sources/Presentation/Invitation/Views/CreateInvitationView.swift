//
//  CreateInvitationView.swift
//  LastDance
//
//  Created by donghee on 11/17/25.
//

import SwiftUI

struct CreateInvitationView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = CreateInvitationViewModel()
    @GestureState private var translation: CGFloat = 0
    @State private var currentIndex: Int = 0

    private let hapticImpact = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("전시 초대")
                        .font(LDFont.heading02)
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: {
                        router.push(.articleArchiving)
                    }) {
                        Image("House")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                }
                .foregroundColor(.black)
                .padding(.top, 20)
                .padding(.horizontal, 24)

                Spacer()
                    .frame(height: 54)

                if viewModel.invitations.isEmpty {
                    // 초대장이 없을 때: 기존 화면
                    VStack(spacing: 0) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .background(LDColor.color5)
                                .cornerRadius(24)
                                .aspectRatio(341 / 526, contentMode: .fit)

                            VStack(spacing: 0) {
                                Text("초대장을 만들어 전시에\n사람들을 초대해보세요")
                                    .font(LDFont.medium03)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(LDColor.color2)

                                Button(action: {
                                    router.push(.selectExhibitionForInvitation)
                                }) {
                                    HStack(alignment: .center, spacing: 10) {
                                        Text("초대장 만들기")
                                            .font(LDFont.medium04)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(LDColor.color2)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(LDColor.color4)
                                    .cornerRadius(24)
                                }
                                .padding(.top, 36)
                            }
                        }
                    }
                    .padding(.horizontal, 26)
                } else {
                    // 초대장이 있을 때: 캐러셀 스타일
                    GeometryReader { geometry in
                        let horizontalPadding: CGFloat = 27
                        let spacing: CGFloat = 14
                        let cardWidth = geometry.size.width - (horizontalPadding * 2)
                        let totalSpacing = spacing + cardWidth

                        HStack(spacing: spacing) {
                            ForEach(Array(viewModel.invitations.enumerated()), id: \.element.id) {
                                index, invitation in
                                InvitationCard(invitation: invitation)
                                    .aspectRatio(341 / 526, contentMode: .fit)
                                    .frame(width: cardWidth)
                                    .scaleEffect(currentIndex == index ? 1.0 : 0.95)
                                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
                                    .onTapGesture {
                                        // 최신 데이터를 다시 fetch해서 넘겨줌
                                        let latestInvitation =
                                            viewModel.getLatestInvitation(
                                                invitationId: invitation.id) ?? invitation
                                        router.push(
                                            .invitationShare(invitation: latestInvitation))
                                    }
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .offset(x: -CGFloat(currentIndex) * totalSpacing + translation)
                        .gesture(
                            DragGesture()
                                .updating($translation) { value, state, _ in
                                    state = value.translation.width
                                }
                                .onEnded { value in
                                    let threshold: CGFloat = 50
                                    let dragDistance = value.translation.width

                                    let previousIndex = currentIndex

                                    if dragDistance > threshold {
                                        currentIndex = max(0, currentIndex - 1)
                                    } else if dragDistance < -threshold {
                                        currentIndex = min(
                                            viewModel.invitations.count - 1, currentIndex + 1)
                                    }

                                    // 페이지가 실제로 변경되었을 때만 햅틱
                                    if currentIndex != previousIndex {
                                        hapticImpact.impactOccurred()
                                    }
                                }
                        )
                    }
                }
                Spacer()
            }
            .background(LDColor.color6)
            // CircleAddButton을 우측 하단에 고정
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        router.push(.selectExhibitionForInvitation)
                    }) {
                        ZStack {
                            Circle()
                                .fill(LDColor.color1)
                                .frame(width: 51, height: 51)
                                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 0)

                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(LDColor.color6)
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            // 서버에서 최신 초대장 목록 가져오기
            viewModel.loadInvitationsFromServer()
        }
        .onChange(of: router.path) { _ in
            // 네비게이션 스택이 변경될 때마다 초대장 목록 새로고침
            viewModel.loadInvitationsFromServer()
        }
    }
}

// MARK: - InvitationCard

private struct InvitationCard: View {
    let invitation: Invitation

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 배경 이미지
            if let coverImageURLString = invitation.coverImageName {
                CachedImage(coverImageURLString)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 341, height: 526)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 341, height: 526)
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
            .frame(width: 341, height: 263)

            // 텍스트 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(invitation.exhibitionTitle)
                    .font(LDFont.heading06)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Text(
                    Date.formatShortDateRange(start: invitation.startDate, end: invitation.endDate)
                )
                .font(LDFont.medium05)
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.bottom, 12)

                HStack(spacing: 4) {
                    Text("방문자")
                        .font(LDFont.medium05)
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(invitation.visitorCount)")
                        .font(LDFont.medium01)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .frame(width: 341, height: 526)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 0)
    }
}

#Preview {
    CreateInvitationView()
        .environmentObject(NavigationRouter())
}

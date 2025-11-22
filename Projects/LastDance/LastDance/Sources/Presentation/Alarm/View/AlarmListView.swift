//
//  AlarmListView.swift
//  LastDance
//
//  Created by 아우신얀 on 11/10/25.
//

import SwiftUI

// MARK: AlarmListView
struct AlarmListView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = AlarmViewModel()
    let userType: UserType

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.notifications.isEmpty {
                DefaultAlarmView()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.notifications) { item in
                            Button(
                                action: {
                                    viewModel.handleNotificationTap(
                                        item, router: router, userType: userType)
                                },
                                label: {
                                    VStack(spacing: 0) {
                                        NotificationCell(item: item)
                                        Divider()
                                    }
                                }
                            )
                            .buttonStyle(NotificationCellButtonStyle())
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    router.popLast()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("알림")
                    .font(LDFont.heading04)
                    .foregroundColor(LDColor.color1)
            }
        }
        .onAppear {
            viewModel.onAlarmViewAppear(userType: userType)
        }
    }
}

// MARK: NotificationCellButtonStyle
struct NotificationCellButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? LDColor.color5 : Color.white)
    }
}

// MARK: NotificationCell
struct NotificationCell: View {
    let item: NotificationItem

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: item.type.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 17, height: 17)
                .padding(2)
                .foregroundColor(LDColor.color4)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.title)
                        .font(LDFont.heading06)
                        .foregroundColor(LDColor.color3)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Spacer()

                    Text(item.timeAgo)
                        .font(LDFont.regular03)
                        .foregroundColor(LDColor.color3)
                }

                Text(item.message)
                    .font(LDFont.medium03)
                    .foregroundColor(LDColor.color1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
}

// MARK: DefaultAlarmView
struct DefaultAlarmView: View {
    var body: some View {
        VStack(spacing: 36) {
            Image("defaultAlarmList")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 119)

            Text("관람객들에게 반응을 받아보세요")
                .font(LDFont.medium03)
                .foregroundStyle(LDColor.color2)
        }
    }
}

#Preview {
    AlarmListView(userType: .viewer)
        .environmentObject(NavigationRouter())
}

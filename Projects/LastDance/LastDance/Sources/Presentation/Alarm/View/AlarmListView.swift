//
//  AlarmListView.swift
//  LastDance
//
//  Created by 아우신얀 on 11/10/25.
//

import SwiftUI

// MARK: AlarmListView
struct AlarmListView: View {
    private let notifications: [NotificationItem] = [
            .init(type: .artist, sender: "조셀초이 : 기억의 지층, 경계를 넘는 시선", message: "'Portrait in front of the wall N.2'에 새로운 메세지가 있어요.", timeAgo: "방금 전"),
            .init(type: .artist, sender: "조셀초이 : 기억의 지층, 경계를 넘는 시선", message: "'Portrait in front of the wall N.2'에 새로운 메세지가 있어요.", timeAgo: "2시간 전"),
            .init(type: .viewer, sender: "조셀초이 : 기억의 지층, 경계를 넘는 시선", message: "'Portrait in front of the wall N.2'에 새로운 메세지가 있어요.", timeAgo: "10월 31일"),
            .init(type: .viewer, sender: "조셀초이 : 기억의 지층, 경계를 넘는 시선", message: "'Portrait in front of the wall N.2'에 새로운 메세지가 있어요.", timeAgo: "10월 31일")
        ]

    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(notifications) { item in
                        Button(action: {
                            // 셀 클릭 시 액션
                        }, label: {
                            VStack(spacing: 0) {
                                NotificationCell(item: item)
                                Divider()
                            }
                        })
                        .buttonStyle(NotificationCellButtonStyle())
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
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
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.sender)
                        .font(LDFont.heading06)
                        .foregroundColor(LDColor.color3)
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

#Preview {
    AlarmListView()
}

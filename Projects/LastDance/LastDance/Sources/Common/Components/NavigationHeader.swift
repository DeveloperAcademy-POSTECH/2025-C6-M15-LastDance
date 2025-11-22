//
//  NavigationHeader.swift
//  LastDance
//
//  Created by 아우신얀 on 11/16/25.
//

import SwiftUI

/// "나의 전시" 타이틀과 알림 버튼을 포함하는 네비게이션 헤더 컴포넌트
struct NavigationHeader: View {
    @StateObject private var alarmViewModel = AlarmViewModel()
    @EnvironmentObject private var router: NavigationRouter

    // UserDefaults에서 userType 가져오기
    private var userType: UserType {
        if let typeString = UserDefaults.standard.string(forKey: UserDefaultsKey.userType.key),
            let type = UserType(rawValue: typeString)
        {
            return type
        }
        return .viewer  // 기본값
    }

    var body: some View {
        HStack {
            Text("exhibition_title")
                .font(LDFont.heading02)
                .foregroundColor(.black)

            Spacer()

            Button(action: {
                router.push(.alarmList(userType: userType))
            }) {
                Image(alarmViewModel.hasNotifications ? "alarm" : "bell")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .foregroundColor(.black)
        .padding(.top, 20)
        .padding(.horizontal, 24)
        .onAppear {
            // UserDefaults에서 UUID 가져오기
            let uuid: String
            switch userType {
            case .artist:
                uuid = UserDefaults.standard.string(forKey: UserDefaultsKey.artistUUID.key) ?? ""
            case .viewer:
                uuid = UserDefaults.standard.string(forKey: UserDefaultsKey.visitorUUID.key) ?? ""
            }

            guard !uuid.isEmpty else {
                Log.error("UUID가 없습니다.")
                return
            }

            // 읽지 않은 알림 개수 조회
            alarmViewModel.loadUnreadCount(uuid: uuid)
        }
    }
}

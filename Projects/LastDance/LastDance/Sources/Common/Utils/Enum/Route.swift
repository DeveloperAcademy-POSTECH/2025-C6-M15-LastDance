//
//  Route.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import Foundation
import UIKit

/// 앱의 모든 화면 경로를 정의한 enum
enum Route: Hashable {
    /// 작가-관람객 종류 선택 뷰
    case identitySelection
    /// 작가 인증 코드 입력 뷰
    case artistCodeInput
    /// 관람객 flow : 나의 전시 아카이빙 뷰
    case audienceArchiving
    /// 작가 flow : 나의 전시 아카이빙 뷰
    case articleArchiving
    /// 관람객 flow : 전시 하나 선택했을때 나오는 작품 목록 뷰
    case exhibitionArchive(exhibitionId: Int)
    /// 촬영 뷰
    case camera
    /// 촬영 확인 뷰
    case captureConfirm(imageData: Data)
    /// 반응 보낸 작품들 아카이빙 뷰 (현재까지 촬영한 작품)
    case archive(id: Int)
    /// 관람객 flow: 반응 전송 완료 뷰
    case completeReaction(exhibitionId: Int)
    /// 작가 flow : 반응 확인 뷰 (작품/메시지 탭)
    case response(artworkId: Int)
    /// 작가 flow : 전시 하나 선택했을때 나오는 작품 목록 뷰
    case artistReactionArchiveView(exhibitionId: Int)
    /// 관람객 flow : 작품 상세와 감상 내용 보기 뷰 (작품/감상 탭)
    case artReaction(artwork: Artwork, artist: Artist?)
    /// 관람객 flow : 작품 상세와 감상 보내기 뷰 (작품/감상 탭)
    case artReactionSend(artworkId: Int, artistId: Int, exhibitionId: Int, imageData: Data)
    /// 알람 목록 뷰
    case alarmList(userType: UserType)
    /// 초대장 생성 뷰
    case createInvitation
    /// 초대장 생성을 위한 전시 선택 뷰
    case selectExhibitionForInvitation
    /// 초대장 상세 내용 작성 뷰
    case invitationDetail(exhibition: Exhibition)
    /// 초대장 공유 뷰
    case invitationShare(invitation: Invitation)
    /// 초대장 수령 뷰
    case receivedInvitation(invitationCode: String)
}

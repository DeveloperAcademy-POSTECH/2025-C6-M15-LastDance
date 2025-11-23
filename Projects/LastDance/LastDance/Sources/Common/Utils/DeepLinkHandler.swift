//
//  DeepLinkHandler.swift
//  LastDance
//
//  Created by donghee, 신얀 on 11/19/25.
//

import Foundation

struct DeepLinkHandler {
    /// URL을 파싱하여 DeepLinkType 반환
    /// - Parameter url: lastdance://invitation/{uuid} 형식의 URL
    /// - Returns: 파싱된 DeepLinkType
    static func parse(_ url: URL) -> DeepLinkType {
        Log.debug("딥링크 파싱 시작: \(url.absoluteString)")

        guard url.scheme == PushDeepLinkConstants.scheme else {
            Log.error("잘못된 URL Scheme: \(url.scheme ?? "nil")")
            return .unknown
        }

        let host = url.host
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        Log.debug("Host: \(host ?? "nil"), Path: \(pathComponents)")

        // lastdance://invitation/{uuid}
        if host == PushDeepLinkConstants.invitationHost, let uuid = pathComponents.first {
            Log.debug("초대장 딥링크 인식 - UUID: \(uuid)")
            return .invitation(uuid: uuid)
        }

        // 푸시알람을 눌렀을때 딥링크 처리
        if host == PushDeepLinkConstants.artworkReactionHost,
            let artworkIdString = pathComponents.first,
            let artworkId = Int(artworkIdString)
        {
            Log.debug("작품 반응 딥링크 인식 - artworkId: \(artworkId)")
            return .artworkReaction(artworkId: artworkId)
        }

        // 관람객 알람 리스트에서 해당 알람 선택 후 딥링크 처리
        if host == "visit",
            pathComponents.count >= 4,
            pathComponents.indices.contains(1),
            pathComponents.indices.contains(2),
            pathComponents[1] == "artwork",
            let artworkId = Int(pathComponents[2])
        {
            Log.debug("관람객 알림 딥링크 인식 - artworkId: \(artworkId)")
            return .artworkReaction(artworkId: artworkId)
        }

        // 작가 알람 리스트에서 해당 알람 선택 후 딥링크 처리
        if host == "exhibition",
            pathComponents.count >= 4,
            pathComponents.indices.contains(1),
            pathComponents.indices.contains(2),
            pathComponents[1] == "artwork",
            let artworkId = Int(pathComponents[2])
        {
            Log.debug("작가 알림 딥링크 인식 - artworkId: \(artworkId)")
            return .artworkReaction(artworkId: artworkId)
        }
        Log.error("알 수 없는 딥링크 형식")
        return .unknown
    }
}

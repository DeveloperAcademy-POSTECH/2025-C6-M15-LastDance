//
//  AppClipHandOffManager.swift
//  LastDance
//
//  Created by 배현진 on 11/12/25.
//

import Foundation

final class AppClipHandOffManager {
    private let defaults = UserDefaults(suiteName: "group.com.lastdance.shared")

    func consumeClipPayload() -> ClipPayload? {
        guard let defaults else { return nil }

        guard
            let visitorUUID = defaults.string(forKey: SharedKeys.visitorUUID),
            let visitorId = defaults.object(forKey: SharedKeys.visitorId) as? Int,
            let visitId = defaults.object(forKey: SharedKeys.visitId) as? Int,
            let exhibitionId = defaults.object(forKey: SharedKeys.exhibitionId) as? Int
        else {
            return nil
        }

        let artworkId = defaults.object(forKey: SharedKeys.lastArtworkId) as? Int

        return ClipPayload(
            visitorUUID: visitorUUID,
            visitorId: visitorId,
            visitId: visitId,
            exhibitionId: exhibitionId,
            artworkId: artworkId
        )
    }
}

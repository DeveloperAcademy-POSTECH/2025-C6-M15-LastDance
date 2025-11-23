//
//  DeepLinkType.swift
//  LastDance
//
//  Created by donghee on 11/19/25.
//

import Foundation

enum DeepLinkType {
    case invitation(uuid: String)
    case artworkReaction(artworkId: Int)
    case unknown
}

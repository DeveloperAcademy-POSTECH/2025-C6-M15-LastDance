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
    case identitySelection
    case audienceArchiving
    case articleArchiving
    case exhibitionList
    case exhibitionDetail(id: Int)
    case exhibitionArchive(exhibitionId: Int)
    case artworkDetail(id: Int, capturedImage: UIImage)
    case camera
    case inputArtworkInfo(image: UIImage, exhibitionId: Int?, artistId: Int?)
    case archive(id: Int)
    case category
    case reactionTags
    case completeReaction
    case articleExhibitionList
    case articleList(selectedExhibitionId: Int)
    case completeArticleList(selectedExhibitionId: Int, selectedArtistId: Int)
    case artistReaction
    case response(artworkId: Int)
    case artistReactionArchiveView(exhibitionId: Int)
    case artReaction(artwork: Artwork, artist: Artist?)
}

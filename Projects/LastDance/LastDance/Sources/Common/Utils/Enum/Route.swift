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
    case exhibitionDetail(id: String)
    case exhibitionArchive(exhibitionId: Int)
    case artworkDetail(id: Int)
    case camera
    case inputArtworkInfo(image: UIImage)
    case archive
    case category
    case completeReaction
    case articleExhibitionList
    case articleList(selectedExhibitionId: String)
    case completeArticleList(selectedExhibitionId: String, selectedArtistId: String)
}

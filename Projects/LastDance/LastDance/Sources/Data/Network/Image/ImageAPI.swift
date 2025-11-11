//
//  ImageAPI.swift
//  LastDance
//
//  Created by 아우신얀 on 10/20/25.
//

import Foundation
import Moya

enum ImageFolder: String {
    case images
    case artworks
    case exhibitions
    case reactions
}

enum ImageAPI {
    case uploadImage(folder: ImageFolder, imageData: Data)
}

extension ImageAPI: BaseTargetType {
    var path: String {
        return "\(APIVersion.version1)/upload"
    }

    var method: Moya.Method {
        switch self {
        case .uploadImage:
            return .post
        }
    }

    var queryParameters: [String: Any]? {
        switch self {
        case let .uploadImage(folder, _):
            return ["folder": folder.rawValue]
        }
    }

    var bodyParameters: (any Codable)? {
        return nil
    }

    var isMultipart: Bool {
        switch self {
        case .uploadImage:
            return true
        }
    }

    var multipartData: [Moya.MultipartFormData]? {
        switch self {
        case let .uploadImage(_, imageData):
            let formData = Moya.MultipartFormData(
                provider: .data(imageData),
                name: "file",
                fileName: "image.jpg",
                mimeType: "image/jpeg"
            )
            return [formData]
        }
    }
}

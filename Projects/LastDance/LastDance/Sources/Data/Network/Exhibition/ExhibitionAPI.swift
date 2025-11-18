//
//  ExhibitionAPI.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Foundation
import Moya

enum ExhibitionAPI {
    case getExhibitions(status: String?, venue_id: Int?)
    case makeExhibition(dto: ExhibitionRequestDto, coverImageData: Data?)
    case getDetailExhibition(exhibition_id: Int)
}

extension ExhibitionAPI: BaseTargetType {
    var path: String {
        switch self {
        case .getExhibitions, .makeExhibition:
            return "\(APIVersion.version1)/exhibitions"
        case .getDetailExhibition(let exhibition_id):
            return "\(APIVersion.version1)/exhibitions/\(exhibition_id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getExhibitions, .getDetailExhibition:
            return .get
        case .makeExhibition:
            return .post
        }
    }

    var queryParameters: [String: Any]? {
        switch self {
        case .getExhibitions(let status, let venue_id):
            var params: [String: Any] = [:]
            if let status = status {
                params["status"] = status
            }
            if let venue_id = venue_id {
                params["venue_id"] = venue_id
            }
            return params.isEmpty ? nil : params
        case .makeExhibition, .getDetailExhibition:
            return nil
        }
    }

    var bodyParameters: Codable? {
        switch self {
        case .getExhibitions, .makeExhibition, .getDetailExhibition:
            return nil
        }
    }

    var isMultipart: Bool {
        switch self {
        case .makeExhibition:
            return true
        default:
            return false
        }
    }

    var multipartData: [Moya.MultipartFormData]? {
        switch self {
        case .makeExhibition(let dto, let coverImageData):
            var parts: [Moya.MultipartFormData] = []

            func addText(_ name: String, _ value: String) {
                if let data = value.data(using: .utf8) {
                    parts.append(.init(provider: .data(data), name: name))
                }
            }

            addText("title", dto.title)
            if let desc = dto.description_text {
                addText("description_text", desc)
            }
            addText("start_date", dto.start_date)
            if let end = dto.end_date {
                addText("end_date", end)
            }
            addText("venue_id", String(dto.venue_id))

            if let artworkIds = dto.artwork_ids,
                let jsonData = try? JSONEncoder().encode(artworkIds),
                let jsonString = String(data: jsonData, encoding: .utf8)
            {
                addText("artwork_ids", jsonString)
            }

            if let data = coverImageData {
                let imagePart = Moya.MultipartFormData(
                    provider: .data(data),
                    name: "cover_image",
                    fileName: "cover.jpg",
                    mimeType: "image/jpeg"
                )
                parts.append(imagePart)
            }

            return parts

        default:
            return nil
        }
    }
}

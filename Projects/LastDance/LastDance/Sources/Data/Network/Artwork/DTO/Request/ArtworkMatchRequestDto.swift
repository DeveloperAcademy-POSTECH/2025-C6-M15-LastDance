//
//  ArtworkMatchRequestDto.swift
//  LastDance
//
//  Created by 배현진 on 11/17/25.
//

struct ArtworkMatchRequestDto: Codable {
    let image_base64: String
    let threshold: Double?

    init(imageBase64: String, threshold: Double? = nil) {
        self.image_base64 = imageBase64
        self.threshold = threshold
    }
}

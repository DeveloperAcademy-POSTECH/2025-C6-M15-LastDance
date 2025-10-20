//
//  Untitled.swift
//  LastDance
//
//  Created by 아우신얀 on 10/15/25.
//

/// UserDefaults 키를 관리하는 enum
enum UserDefaultsKey: String {
    case selectedCategories
    case seed = "seed.v1"
    case userType

    /// 방문객 UUID 정보 Key
    case visitorUUID

    /// 작가 UUID 정보 Key
    case artistUUID

    /// 업로드된 이미지 URL Key
    case uploadedImageUrl
    
    /// 첫 리액션 등록 여부
    case hasRegisteredFirstReaction
    
    var key: String {
        return self.rawValue
    }
}

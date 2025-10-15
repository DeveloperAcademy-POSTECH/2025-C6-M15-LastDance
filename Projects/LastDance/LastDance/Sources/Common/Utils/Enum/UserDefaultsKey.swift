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

    var key: String {
        return self.rawValue
    }
}

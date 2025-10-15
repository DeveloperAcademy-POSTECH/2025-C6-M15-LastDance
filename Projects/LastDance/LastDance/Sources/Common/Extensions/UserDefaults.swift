//
//  UserDefaults.swift
//  LastDance
//
//  Created by 아우신얀 on 10/15/25.
//

import Foundation

extension UserDefaults {
    /// String 배열 저장
    func set(_ value: [String], forKey key: UserDefaultsKey) {
        set(value, forKey: key.key)
    }

    /// String 배열 가져오기
    func stringArray(forKey key: UserDefaultsKey) -> [String]? {
        return array(forKey: key.key) as? [String]
    }

    /// Bool 값 저장
    func set(_ value: Bool, forKey key: UserDefaultsKey) {
        set(value, forKey: key.key)
    }

    /// Bool 값 가져오기
    func bool(forKey key: UserDefaultsKey) -> Bool {
        return bool(forKey: key.key)
    }

    /// 값 삭제
    func remove(forKey key: UserDefaultsKey) {
        removeObject(forKey: key.key)
    }
}

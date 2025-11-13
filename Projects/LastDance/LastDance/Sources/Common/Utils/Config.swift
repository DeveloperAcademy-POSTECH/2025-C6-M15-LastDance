//
//  Config.swift
//  LastDance
//
//  Created by 아우신얀 on 10/15/25.
//
import Foundation

enum Config {
    private static let infoDictionarys: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist cannot found.")
        }
        return dict
    }()
}

extension Config {
    static let baseURL: String = {
        guard let key = Config.infoDictionarys[NetworkConstants.baseURLKey] as? String else {
            fatalError("⛔️BASE_URL is not set in plist for this configuration⛔️")
        }
        return key
    }()
}

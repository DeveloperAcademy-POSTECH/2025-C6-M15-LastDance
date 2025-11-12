//
//  ProfanityFilter.swift
//  LastDance
//
//  Created by 배현진 on 11/13/25.
//

import SwiftUI

/// 금칙어 로더 & 검사기
final class ProfanityFilter {
    private(set) var words: [String] = []

    // 한글 + 영문 조합을 대비한 정규화
    private func normalized(_ str: String) -> String {
        (str.applyingTransform(.init("NFKC"), reverse: false) ?? str).lowercased()
    }
    
    func load(from data: Data) {
        guard let text = String(data: data, encoding: .utf8) else {
            words = []
            return
        }
        words = text
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map(normalized)
    }

    func containsProfanity(in message: String) -> Bool {
        let norm = message.lowercased()
        return words.contains { norm.contains($0.lowercased()) }
    }
}

//
//  ProfanityFilter.swift
//  LastDance
//
//  Created by 배현진 on 11/13/25.
//

import Foundation

/// 금칙어 로더 & 검사기
final class ProfanityFilter {
    private(set) var words: [String] = []
    
    /// badword_filter.txt에서 불러오기
    func load(from data: Data) {
        guard let text = String(data: data, encoding: .utf8) else {
            words = []
            return
        }

        let lines = text
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        self.words = lines.map { normalized($0) }

        Log.debug("ProfanityFilter.load -> words.count = \(words.count)")
    }

    /// 실제 필터링 API (반드시 여기만 써야 함)
    func containsProfanity(in message: String) -> Bool {
        let normMsg = normalized(message)

        if let hit = words.first(where: { normMsg.contains($0) }) {
            Log.debug("hit word = \(hit)")
            return true
        } else {
            Log.debug("no hit")
            return false
        }
    }

    /// 정규화 진행
    private func normalized(_ str: String) -> String {
        let step1 = str.removingZeroWidth()
        let step2 = step1.nfkcNormalized()
        let step3 = step2.normalizeAllJamo()
        let step4 = step3.composeHangulJamo()
        return step4.lowercased()
    }
}

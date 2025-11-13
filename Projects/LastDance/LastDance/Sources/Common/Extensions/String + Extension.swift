//
//  String + Extension.swift
//  LastDance
//
//  Created by 배현진 on 11/13/25.
//

import Foundation

// MARK: - Zero-width 문자 제거
extension String {
    func removingZeroWidth() -> String {
        let zeroWidthScalars: [UnicodeScalar] = [
            "\u{200B}", // ZWSP
            "\u{200C}", // ZWNJ
            "\u{200D}", // ZWJ
            "\u{2060}", // WJ
            "\u{FEFF}"  // BOM
        ]
        return String(self.unicodeScalars.filter { !zeroWidthScalars.contains($0) })
    }
}

// MARK: - NFKC 정규화
extension String {
    func nfkcNormalized() -> String {
        return self.applyingTransform(.init("NFKC"), reverse: false) ?? self
    }
}

// MARK: - 여러 형태의 자모 유니코드를 Compatibility Jamo로 정규화
extension String {
    func normalizeAllJamo() -> String {
        return String(
            self.unicodeScalars.map { scalar -> Character in
                switch scalar.value {
                // Hangul Jamo
                case 0x1100...0x11FF:
                    return Character(UnicodeScalar((scalar.value - 0x1100) + 0x3130)!)
                // Compatibility Jamo
                case 0x3130...0x318F:
                    return Character(scalar)
                // Halfwidth/Fullwidth Jamo
                case 0xFFA0...0xFFDC:
                    let offset = scalar.value - 0xFFA0
                    if offset < (0x318F - 0x3130) {
                        return Character(UnicodeScalar(0x3130 + offset)!)
                    }
                    return Character(scalar)
                default:
                    return Character(scalar)
                }
            }
        )
    }
}

// MARK: - 한글 자모 → 완성형 조합
extension String {
    private struct HangulConstants {
        // 초성 (L) 테이블
        static let LTables: [Character] = [
            "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ",
            "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ",
            "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
        ]
        
        // 중성 (V) 테이블
        static let VTables: [Character] = [
            "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ",
            "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ",
            "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"
        ]
        
        // 종성 (T) 테이블 (첫 번째는 공백/받침 없음)
        static let TTables: [String] = [
            "", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ",
            "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ",
            "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ",
            "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
        ]
    }
    
    func composeHangulJamo() -> String {
        var result = ""
        var buffers: [Character] = []

        func flush() {
            guard !buffers.isEmpty else { return }

            if buffers.count == 1 {
                result.append(buffers[0])
                buffers.removeAll()
                return
            }

            let cho = buffers[0]
            let jung = buffers[1]
            let jong = buffers.count >= 3 ? String(buffers[2]) : ""

            guard let choIndex = HangulConstants.LTables.firstIndex(of: cho),
                  let jungIndex = HangulConstants.VTables.firstIndex(of: jung),
                  let jongIndex = HangulConstants.TTables.firstIndex(of: jong) else {
                result += String(buffers)
                buffers.removeAll()
                return
            }

            let sBase = 0xAC00
            let unicode = sBase + (((choIndex * 21) + jungIndex) * 28) + jongIndex

            if let scalar = UnicodeScalar(unicode) {
                result.append(Character(scalar))
            } else {
                result += String(buffers)
            }

            buffers.removeAll()
        }

        for character in self {
            let isCho = HangulConstants.LTables.contains(character)
            let isJung = HangulConstants.VTables.contains(character)
            let isJong = HangulConstants.TTables.contains(String(character))

            if isCho || isJung || isJong {
                buffers.append(character)
                if buffers.count == 3 { flush() }
            } else {
                flush()
                result.append(character)
            }
        }

        flush()
        return result
    }
}

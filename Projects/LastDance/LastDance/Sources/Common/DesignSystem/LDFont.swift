//
//  LDFont.swift
//  LastDance
//
//  Created by 배현진 on 10/21/25.
//

import SwiftUI

enum LDFont {
    /// pretendard, size: 28 , weight: semibold
    static let heading01: Font = .custom("Pretendard-SemiBold", size: 28)
    /// pretendard, size: 21, weight: bold
    static let heading02: Font = .custom("Pretendard-Bold", size: 21)
    /// pretendard, size: 21 , weight: semibold
    static let heading03: Font = .custom("Pretendard-SemiBold", size: 21)
    /// pretendard, size: 18 , weight: semibold
    static let heading04: Font = .custom("Pretendard-SemiBold", size: 18)
    /// pretendard, size: 17 , weight: semibold
    static let heading05: Font = .custom("Pretendard-SemiBold", size: 17)
    /// pretendard, size: 16 , weight: semibold
    static let heading06: Font = .custom("Pretendard-SemiBold", size: 16)
    /// pretendard, size: 18 , weight: regular
    static let body01: Font = .custom("Pretendard-Regular", size: 18)
    /// pretendard, size: 16 , weight: regular
    static let body02: Font = .custom("Pretendard-Regular", size: 16)
    /// pretendard, size: 14 , weight: regular
    static let body03: Font = .custom("Pretendard-Regular", size: 14)
    
    /// system, size: 18, weight: semibold
    static let barButton: Font = .system(size: 18, weight: .semibold)
}

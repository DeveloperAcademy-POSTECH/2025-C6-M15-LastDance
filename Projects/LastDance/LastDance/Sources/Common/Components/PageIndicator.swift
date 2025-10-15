//
//  PageIndicator.swift
//  LastDance
//
//  Created by donghee on 10/14/25.
//

import SwiftUI

/// 페이지 인디케이터 컴포넌트
struct PageIndicator: View {
    let totalPages: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<totalPages, id: \.self) { index in
                Rectangle()
                    .fill(index == currentPage ? Color.black : Color.black.opacity(0.18))
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PageIndicator(totalPages: 2, currentPage: 0)
        PageIndicator(totalPages: 2, currentPage: 1)
        PageIndicator(totalPages: 2, currentPage: 2)

    }
    .padding()
}

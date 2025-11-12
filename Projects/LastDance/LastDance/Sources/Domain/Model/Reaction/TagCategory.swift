//
//  TagCategory.swift
//  LastDance
//
//  Created by 배현진 on 10/19/25.
//

import SwiftUI

struct TagCategory: Identifiable, Hashable {
    let id: Int
    let name: String
    let colorHex: String
    var color: Color {
        Color(hex: colorHex)
    }

    let tags: [Tag]
}

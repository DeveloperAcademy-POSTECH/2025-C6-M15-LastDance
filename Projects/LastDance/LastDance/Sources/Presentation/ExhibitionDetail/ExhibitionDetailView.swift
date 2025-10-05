//
//  ExhibitionDetailView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

struct ExhibitionDetailView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ExhibitionDetailViewModel()
    
    let exhibitionId: String

    var body: some View {
        Text("ExhibitionDetailView")
    }
}

//
//  ExhibitionListView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

struct ExhibitionListView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ExhibitionListViewModel()
    
    var body: some View {
        Text("ExhibitionListView")
    }
}

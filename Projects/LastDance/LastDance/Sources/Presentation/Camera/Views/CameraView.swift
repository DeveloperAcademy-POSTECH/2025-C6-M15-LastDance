//
//  CameraView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI

struct CameraView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        Text("CameraView")
    }
}

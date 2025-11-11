////
////  ClipTapBarView.swift
////  LastDance
////
////  Created by 배현진 on 11/11/25.
////
//
//import SwiftUI
//
//struct ClipTabBarView: View {
//    @Binding var selectedTab: ArtReactionTab
//    
//    var body: some View {
//        HStack(spacing: 0) {
//            Button {
//                selectedTab = .artwork
//            } label: {
//                VStack(spacing: 8) {
//                    Text("작품")
//                        .font(.system(size: 17, weight: .semibold))
//                        .foregroundColor(selectedTab == .artwork ? .black : Color.color2)
//                    Rectangle()
//                        .fill(selectedTab == .artwork ? Color.black : Color.color5)
//                        .frame(height: 2)
//                }
//            }
//            .frame(maxWidth: .infinity)
//            
//            Button {
//                selectedTab = .reaction
//            } label: {
//                VStack(spacing: 8) {
//                    Text("감상")
//                        .font(.system(size: 17, weight: .semibold))
//                        .foregroundColor(selectedTab == .reaction ? .black : Color.color2)
//                    Rectangle()
//                        .fill(selectedTab == .reaction ? Color.black : Color.color5)
//                        .frame(height: 2)
//                }
//            }
//            .frame(maxWidth: .infinity)
//        }
//        .padding(.horizontal, 20)
//    }
//}

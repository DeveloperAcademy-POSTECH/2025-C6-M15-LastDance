//
//  ArchiveViewHome.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftUI

struct ArchiveViewHome: View {
    @StateObject private var viewModel = ArchiveViewHomeViewModel()
    @EnvironmentObject private var router: NavigationRouter
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 상단 제목
                HStack {
                    Text("나의 전시")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // 전시 포스터 영역 (왼쪽 정렬)
                HStack {
                    Rectangle()
                        .stroke(Color.black, lineWidth: 1)
                        .frame(width: 155, height: 219)
                        .overlay(
                            ZStack {
                                
                                Text("전시 포스터")
                                    .font(.custom("Pretendard", size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                        )
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                
                // 전시명
                HStack {
                    Text(viewModel.exhibitionTitle)
                        .font(.custom("Pretendard", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // 관람 일자
                HStack {
                    Text(viewModel.visitDateString)
                        .font(.custom("Pretendard", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                
                Spacer()
            }
            
            // 플로팅 버튼 (우측 하단)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // TODO: 새 전시 추가 액션
                        router.push(.exhibitionList)
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 82, height: 82)
                            .background(Color.gray.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

#Preview {
    ArchiveViewHome()
        .environmentObject(NavigationRouter())
}


//
//  CategoryView.swift
//  LastDance
//
//  Created by 신얀 on 10/11/25.
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ReactionInputViewModel()
    @State private var selectedCategories: Set<String> = []
    
    // 임시 카테고리
    let categories = [
        "음식", "여행", "운동", "음악",
        "영화", "독서", "게임", "쇼핑",
        "카페", "산책", "요리", "공부",
        "친구", "가족", "데이트", "휴식",
        "업무", "취미", "건강", "문화",
        "예술", "자연", "기술", "패션",
        "뷰티", "반려동물", "드라이브", "사진",
        "축제", "전시", "공연", "스포츠"
    ]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("태그")
                .padding(.leading, 27)
            
            Spacer().frame(height: 10)
            
            Text("최대 4개 선택할 수 있어요")
                .padding(.leading, 27)
            
            Spacer().frame(height: 20)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: viewModel.selectedCategories.contains(category)
                    ) {
                        viewModel.toggleCategory(category)
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            BottomButton(text: "다음",
                         isEnabled: !viewModel.selectedCategories.isEmpty,
                         action: {
                UserDefaults.standard.set(Array(viewModel.selectedCategories), forKey: .selectedCategories)
                router.push(.artworkDetail(id: 1))
            })
        }
        .navigationTitle("반응 남기기")
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(viewModel)
        .onAppear {
            // TODO: - 카테고리와 태그 서버 통신 확인용 (이후 제거 필요)
            viewModel.loadTagsByCategory()
        }
    }
}


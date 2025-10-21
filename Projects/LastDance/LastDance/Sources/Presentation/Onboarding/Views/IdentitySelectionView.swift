//
//  IdentitySelectionView.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import SwiftUI

// MARK: - Main View

/// 사용자 정체성 선택 뷰 (작가/관람객)
struct IdentitySelectionView: View {
    @StateObject private var viewModel = IdentitySelectionViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            IdentitySelectionTitleSection()
            
            Spacer().frame(height: 40)
            
            IdentitySelectionButtons(viewModel: viewModel)
            
            Spacer()
            
            IdentitySelectionNextButton(viewModel: viewModel)
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .onAppear {
            // TODO: - 전시장소 데이터 가져오기 확인용 (이후 제거 필요)
            viewModel.loadAllVenues()
        }
    }
}

// MARK: - Subviews

struct IdentitySelectionTitleSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("어떤 방식으로 전시에 참여하고 싶나요?")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.black)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 80)
        .padding(.horizontal, 20)
    }
}

struct IdentitySelectionButtons: View {
    @ObservedObject var viewModel: IdentitySelectionViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            IdentityCardButton(
                icon: "artist",
                title: "작가",
                subtitle: "내 작품에 대한 반응을 확인해요",
                isSelected: viewModel.selectedType == .artist
            ) {
                viewModel.selectUserType(.artist)
            }
            
            IdentityCardButton(
                icon: "audience",
                title: "관람객",
                subtitle: "작가에게 생생한 반응을 전달해요",
                isSelected: viewModel.selectedType == .viewer
            ) {
                viewModel.selectUserType(.viewer)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct IdentityCardButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(icon)
                    .resizable()
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(red: 0.97, green: 0.97, blue: 0.97) : Color.white)
                    .stroke(
                        isSelected ? Color(red: 0.14, green: 0.14, blue: 0.14) : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 1.8 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color(red: 0.14, green: 0.14, blue: 0.14).opacity(0.24) : Color.clear,
                radius: isSelected ? 1 : 0,
                x: 0,
                y: 0
            )
        }
    }
}

struct IdentitySelectionNextButton: View {
    @EnvironmentObject private var router: NavigationRouter
    @ObservedObject var viewModel: IdentitySelectionViewModel
    
    var body: some View {
        BottomButton(
            text: "다음",
            isEnabled: viewModel.selectedType != nil
        ) {
            viewModel.confirmSelection()
            
            guard let selectedType = viewModel.selectedType else { return }
            switch selectedType {
            case .artist:
                router.push(.articleArchiving)
            case .viewer:
                router.push(.audienceArchiving)
            }
        }
    }
}

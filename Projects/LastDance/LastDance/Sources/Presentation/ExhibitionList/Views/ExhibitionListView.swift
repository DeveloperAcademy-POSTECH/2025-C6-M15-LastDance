//
//  ExhibitionListView.swift
//  LastDance
//
//  Created by 배현진 on 10/5/25.
//

import SwiftUI
import SwiftData

struct ExhibitionListView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel = ExhibitionListViewModel()
    @Query private var exhibitions: [Exhibition]

    var body: some View {
        VStack(spacing: 0) {
            titleSection

            ExhibitionList

            Spacer()

            RegisterButton
        }
//        .padding(.horizontal, 20)
        .padding(.bottom, 34)
        .navigationBarBackButtonHidden(false)
        .navigationTitle("전시찾기")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.getExhibitions()
            viewModel.makeExhibitionList()
        }
    }

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("관람하려 온 전시를 알려주세요")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("전시명")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6))
                .padding(.top, 24)
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
        .padding(.horizontal, 20)
    }

    var ExhibitionList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(exhibitions, id: \.id) { exhibition in
                    ExhibitionRow(
                        exhibition: exhibition,
                        isSelected: viewModel.selectedExhibitionId == exhibition.id
                    ) {
                        viewModel.selectExhibition(exhibition)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    var RegisterButton: some View {
        BottomButton(text: "등록하기") {
            viewModel.tapRegisterButton()
        }
    }
}

/// 전시 목록 행 컴포넌트
struct ExhibitionRow: View {
    let exhibition: Exhibition
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(exhibition.title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .inset(by: 1)
                        .stroke(isSelected ? Color.black : Color.black.opacity(0.18), lineWidth: isSelected ? 2 : 1)
                )
        }
        .padding(.bottom, 8)
    }
}
#Preview{
    ExhibitionListView()
}

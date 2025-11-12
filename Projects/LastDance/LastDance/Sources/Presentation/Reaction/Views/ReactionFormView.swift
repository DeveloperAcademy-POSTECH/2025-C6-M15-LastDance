//
//  ReactionFormView.swift
//  LastDance
//
//  Created by 신얀 on 10/13/25.
//

import SwiftData
import SwiftUI

struct ReactionFormView: View {
    let artworkId: Int
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var router: NavigationRouter
    @EnvironmentObject var viewModel: ReactionInputViewModel

    @State private var showCategorySheet = false

    private let placeholder = "욕설, 비속어 사용 시 전송이 제한될 수 있습니다."
    private var hasSelectedEmotion: Bool {
        !viewModel.selectedCategories.isEmpty || !viewModel.selectedTagsName.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("반응 남기기")
                .font(LDFont.heading02)
                .foregroundColor(.black)

            Spacer().frame(height: 14)

            CategoryTag

            Spacer().frame(height: 27)

            MessageEditor
        }
        .padding(.horizontal, 28)
        .onAppear {
            if let savedCategories = UserDefaults.standard.stringArray(
                forKey: .selectedCategories
            ) {
                viewModel.selectedCategories = Set(savedCategories)
            }
            Log.debug("선택된 카테고리: \(viewModel.selectedCategories)")
        }
    }

    @ViewBuilder
    private var CategoryTag: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                if hasSelectedEmotion {
                    Button {
                        router.push(.category)
                    } label: {
                        HStack(spacing: 6) {
                            Text("감정 태그")
                                .bold()
                                .foregroundColor(LDColor.color1)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("감정 태그")
                        .bold()
                        .foregroundColor(LDColor.color1)
                }

                Spacer()
            }

            if !hasSelectedEmotion {
                Button(
                    action: { router.push(.category) },
                    label: {
                        HStack {
                            Text("지금 떠오르는 감정을 표현해보세요")
                                .font(LDFont.regular02)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(
                                    LDColor.color2
                                )
                                .lineSpacing(5)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: 15, height: 20)
                                .padding(.vertical, 4)
                                .foregroundColor(LDColor.color2)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(LDColor.color6)
                        .cornerRadius(12)
                    }
                )
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    if !viewModel.selectedCategories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(viewModel.selectedCategories).sorted(), id: \.self) {
                                    categoryName in
                                    let category = viewModel.categories.first {
                                        $0.name == categoryName
                                    }
                                    ReactionTag(
                                        text: categoryName,
                                        color: Color(hex: category?.colorHex ?? "#FFFFFF")
                                    )
                                }
                            }
                        }
                    }

                    if !viewModel.selectedTagsName.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(viewModel.selectedTagsName).sorted(), id: \.self) {
                                    tagName in
                                    ReactionTag(
                                        text: tagName,
                                        color: viewModel.findColorForTag(tagName: tagName)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var MessageEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("메시지")
                .font(LDFont.heading04)

            VStack(alignment: .trailing, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(LDColor.color6)
                        .frame(minHeight: 100, maxHeight: 152)
                        .cornerRadius(4)

                    if viewModel.message.isEmpty {
                        Text(placeholder)
                            .foregroundColor(
                                LDColor.gray2
                            )
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $viewModel.message)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .tint(LDColor.gray5)
                        .padding(.top, 3)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                        .padding(.bottom, 10)
                        .frame(height: 152)
                        .onChange(of: viewModel.message) { newValue in
                            viewModel.updateMessage(newValue: newValue)
                        }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(LDColor.color6.opacity(0.3), lineWidth: 1)
                )

                HStack(spacing: 0) {
                    Text("\(viewModel.message.count)")
                        .font(LDFont.regular02)
                        .foregroundStyle(
                            !viewModel.message.isEmpty ? .black : .gray
                        )

                    Text("/\(viewModel.limit)")
                        .font(LDFont.medium05)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

//
//  ReactionFormView.swift
//  LastDance
//
//  Created by 신얀 on 10/13/25.
//

import SwiftUI
import SwiftData

struct ReactionFormView: View {
    let artworkId: String
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: ReactionInputViewModel

    private let placeholder = "욕설, 비속어 사용 시 전송이 제한될 수 있습니다."

    var body: some View {
        VStack(alignment: .leading) {
            Text("반응 남기기")
                .font(.title2)
                .fontWeight(.bold)

            Spacer().frame(height: 14)

            CategoryTag

            Spacer().frame(height: 27)

            MessageEditor
        }
        .padding(.horizontal, 28)
        .onAppear {
            if let savedCategories = UserDefaults.standard.stringArray(forKey: .selectedCategories) {
                viewModel.selectedCategories = Set(savedCategories)
            }
            Log.debug("[ReactionFormView]: \(viewModel.selectedCategories)")
        }
    }

    @ViewBuilder
    private var CategoryTag: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("태그*")
                .bold()

            HStack {
                Text(
                    Array(viewModel.selectedCategories).joined(
                        separator: ", "
                    )
                )
                .foregroundColor(.black)
            }
        }
    }

    @ViewBuilder
    private var MessageEditor: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("메시지")

            VStack(alignment: .trailing, spacing: 8) {
                ZStack(alignment: .topLeading) {

                    Rectangle()
                        .fill(Color.white)
                        .frame(minHeight: 100, maxHeight: 152)
                        .cornerRadius(4)

                    if viewModel.message.isEmpty {
                        Text(placeholder)
                            .foregroundColor(
                                Color(red: 0.79, green: 0.79, blue: 0.79)
                            )
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $viewModel.message)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .tint(Color(red: 0.35, green: 0.35, blue: 0.35))
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
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )

                HStack(spacing: 0) {
                    Text("\(viewModel.message.count)")
                        .font(.caption)
                        .foregroundStyle(!viewModel.message.isEmpty ? .black : .gray)

                    Text("/\(viewModel.limit)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }

        }
    }
}

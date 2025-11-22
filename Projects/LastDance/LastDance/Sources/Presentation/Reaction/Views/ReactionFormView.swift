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

    private let placeholder = ReactionConstants.messagePlaceholder

    var body: some View {
        VStack(alignment: .leading) {
            Text("반응 남기기")
                .font(LDFont.heading02)
                .foregroundColor(.black)

            Spacer().frame(height: 27)

            MessageEditor
        }
        .padding(.horizontal, 28)
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

//
//  ArtworkDetailView.swift
//  LastDance
//
//  Created by 신얀 on 10/10/25.
//

import SwiftUI

struct ArtworkDetailView: View {
    @State private var message: String = ""  // 반응을 남기기 위한 textEditor 메세지
    private let placeholder = "욕설, 비속어 사용 시 전송이 제한될 수 있습니다."
    private let limit = 500

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("작품 이미지")

                    Spacer().frame(height: 73)

                    VStack(alignment: .leading) {

                        Text("작품 제목")

                        Spacer().frame(height: 17)

                        Text("작가명")

                        Spacer().frame(height: 63)

                        Text("반응 남기기")

                        Spacer().frame(height: 20)

                        CategoryTag

                        Spacer().frame(height: 21)

                        MessageEditor
  
                    }
                    .padding(.horizontal, 10)
                    
                    Spacer()

                }
                .padding(.horizontal, 20)
            }
            BottomButton
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle("반응남기기", displayMode: .inline)
    }
    
    @ViewBuilder
    private var CategoryTag: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("태그")

            Button(
                action: {

                },
                label: {
                    ZStack {
                        Rectangle()
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: 46,
                                alignment: .leading
                            )
                            .foregroundColor(.gray.opacity(0.1))
                        HStack {
                            Text("태그 선택하기")
                        }
                        .padding(10)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: 46,
                            alignment: .leading
                        )
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    private var MessageEditor: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("메시지")

            VStack(alignment: .trailing, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(minHeight: 100)
                        .cornerRadius(4)
                    
                    if message.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .padding(10)
                            .allowsHitTesting(false)
                    }
                    
                    TextEditor(text: $message)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 5)
                        .frame(minHeight: 100)
                        .onChange(of: message) { newValue in
                            if newValue.count > limit {
                                message = String(newValue.prefix(limit))
                            }
                        }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                // Character count
                Text("\(message.count)/\(limit)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

        }
    }
    
    @ViewBuilder
    private var BottomButton: some View {
        Button(
            action: {

            },
            label: {
                HStack {
                    Text("전송하기")
                        .foregroundStyle(.black)
                }
            }
        )
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .center)
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(.black, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 35)
    }
}

#Preview {
    ArtworkDetailView()
}

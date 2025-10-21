//
//  ArtReactionView.swift
//  LastDance
//
//  Created by 광로 on 10/20/25.
//

import SwiftUI
import UIKit

struct ArtReactionView: View {
    let artwork: Artwork
    let artist: Artist?
    
    @StateObject private var viewModel: ArtReactionViewModel
    @EnvironmentObject private var router: NavigationRouter
    @State private var selectedTab: ArtReactionTab = .artwork
    @State private var scrollOffset: CGFloat = 0
    
    init(artwork: Artwork, artist: Artist?) {
        self.artwork = artwork
        self.artist = artist
        _viewModel = StateObject(wrappedValue: ArtReactionViewModel(artworkId: artwork.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 뒤로가기 버튼
            HStack {
                Button(action: {
                    router.popLast()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(LDColor.color1)
                        .frame(width: 44, height: 44)
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.top, 12)
            .padding(.bottom, 0)
            .background(LDColor.color6)
            // 고정된 탭 바
            if viewModel.isTabBarFixed(for: scrollOffset) {
                TabBarView(selectedTab: $selectedTab)
                    .background(LDColor.color6)
                    .padding(.top, 0)
            }
            // 스크롤 가능한 콘텐츠
            ScrollViewObserver(scrollOffset: $scrollOffset, resetTrigger: selectedTab) {
                VStack(spacing: 0) {
                    // 작품 이미지
                    Image(artwork.thumbnailURL ?? "mock_artworkImage_01")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: viewModel.imageWidth(for: scrollOffset),
                            height: viewModel.imageHeight(for: scrollOffset)
                        )
                        .clipped()
                        .cornerRadius(24)
                        .animation(.easeInOut(duration: 0.2), value: scrollOffset)
                    // 탭 바
                    if !viewModel.isTabBarFixed(for: scrollOffset) {
                        TabBarView(selectedTab: $selectedTab)
                            .padding(.top, 24)
                    }
                    // 탭 콘텐츠
                    if selectedTab == .artwork {
                        // 작품 정보
                        VStack(alignment: .leading, spacing: 16) {
                            Text(artwork.title)
                                .font(LDFont.medium01)
                                .foregroundColor(LDColor.color1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if let artistName = artist?.name {
                                HStack {
                                    Text(artistName)
                                        .font(LDFont.medium04)
                                        .foregroundColor(LDColor.color6)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(LDColor.color1)
                                        .cornerRadius(20)
                                    
                                    Spacer()
                                }
                            }
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                .frame(height: 0.5)
                                .foregroundColor(LDColor.color3)
                            
                            Text("작품 설명")
                                .font(LDFont.regular02)
                                .foregroundColor(LDColor.color2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer(minLength: 400)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    } else {
                        // 감상 탭
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.2)
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .padding(.top, 24)
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(viewModel.reactions, id: \.id) { reaction in
                                    VStack(alignment: .leading, spacing: 16) {
                                        // 감정 태그 섹션
                                        if !reaction.category.isEmpty {
                                            VStack(alignment: .leading, spacing: 12) {
                                                Text("감정 태그")
                                                    .font(LDFont.heading04)
                                                    .foregroundColor(LDColor.color1)
                                                
                                                VStack(alignment: .leading, spacing: 8) {
                                                    ForEach(reaction.category, id: \.self) { tag in
                                                        HStack(spacing: 8) {
                                                            Circle()
                                                                .fill(Color.red)
                                                                .frame(width: 8, height: 8)
                                                            
                                                            Text(tag)
                                                                .font(LDFont.regular02)
                                                                .foregroundColor(LDColor.color1)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        // 감상평 섹션
                                        if let comment = reaction.comment, !comment.isEmpty {
                                            VStack(alignment: .leading, spacing: 12) {
                                                Text("감상평")
                                                    .font(LDFont.heading04)
                                                    .foregroundColor(LDColor.color1)
                                                
                                                Text(comment)
                                                    .font(LDFont.regular02)
                                                    .foregroundColor(LDColor.color2)
                                                    .lineSpacing(4)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                    }
                                }
                                
                                Spacer(minLength: -200)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .background(LDColor.color6)
            .onAppear {
                viewModel.loadReactions()
            }
        }
    }
}

// MARK: - TabBarView Component
struct TabBarView: View {
    @Binding var selectedTab: ArtReactionTab
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                selectedTab = .artwork
            }) {
                VStack(spacing: 8) {
                    Text("작품")
                        .font(LDFont.heading04)
                        .foregroundColor(selectedTab == .artwork ? LDColor.color1 : LDColor.color2)
                    
                    Rectangle()
                        .fill(selectedTab == .artwork ? LDColor.color1 : Color.clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
            
            Button(action: {
                selectedTab = .reaction
            }) {
                VStack(spacing: 8) {
                    Text("감상")
                        .font(LDFont.heading04)
                        .foregroundColor(selectedTab == .reaction ? LDColor.color1 : LDColor.color2)
                    
                    Rectangle()
                        .fill(selectedTab == .reaction ? LDColor.color1 : Color.clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - ScrollOffsetPreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - ScrollViewObserver
struct ScrollViewObserver<Content: View>: UIViewRepresentable {
    let content: Content
    @Binding var scrollOffset: CGFloat
    let resetTrigger: AnyHashable // 탭 변경 감지용
    
    init(scrollOffset: Binding<CGFloat>, resetTrigger: AnyHashable, @ViewBuilder content: () -> Content) {
        _scrollOffset = scrollOffset
        self.resetTrigger = resetTrigger
        self.content = content()
    }
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        context.coordinator.hostingController = hostingController
        
        return scrollView
    }
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController?.rootView = content
        
        // resetTrigger가 변경되면 스크롤 리셋
        if context.coordinator.previousResetTrigger != resetTrigger {
            context.coordinator.previousResetTrigger = resetTrigger
            
            // 즉시 스크롤 리셋
            uiView.contentOffset = .zero
            
            DispatchQueue.main.async {
                self.scrollOffset = 0
            }
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(scrollOffset: $scrollOffset)
    }
    class Coordinator: NSObject, UIScrollViewDelegate {
        @Binding var scrollOffset: CGFloat
        var hostingController: UIHostingController<Content>?
        var previousResetTrigger: AnyHashable?
        
        init(scrollOffset: Binding<CGFloat>) {
            _scrollOffset = scrollOffset
        }
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = max(0, scrollView.contentOffset.y)
            DispatchQueue.main.async {
                self.scrollOffset = offset
            }
        }
    }
}

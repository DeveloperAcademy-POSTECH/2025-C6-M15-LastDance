//
//  SnappingScrollView.swift
//  LastDance
//
//  Created by 배현진 on 11/23/25.
//

import SwiftUI

struct SnappingScrollView<Content: View>: UIViewRepresentable {
    // SwiftUI 쪽에서 내려주는 콘텐츠
    private let content: () -> Content
    // 스크롤 콜백 (offset, scrollView)
    private let onScroll: (CGFloat, UIScrollView) -> Void
    // 새로고침 콜백
    private let onRefresh: (() -> Void)?

    init(
        @ViewBuilder content: @escaping () -> Content,
        onScroll: @escaping (CGFloat, UIScrollView) -> Void,
        onRefresh: (() -> Void)? = nil
    ) {
        self.content = content
        self.onScroll = onScroll
        self.onRefresh = onRefresh
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true

        // UIRefreshControl 추가
        if onRefresh != nil {
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = UIColor(Color.gray)
            refreshControl.addTarget(
                context.coordinator,
                action: #selector(Coordinator.handleRefresh),
                for: .valueChanged
            )
            scrollView.refreshControl = refreshControl
            context.coordinator.refreshControl = refreshControl
        }

        // SwiftUI 뷰를 담을 호스팅 컨트롤러
        let hosting = UIHostingController(rootView: content())
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear

        scrollView.addSubview(hosting.view)

        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hosting.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // 나중에 update할 수 있도록 coordinator에 보관
        context.coordinator.hostingController = hosting
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // SwiftUI의 상태 변경 → rootView 교체
        context.coordinator.hostingController?.rootView = content()
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: SnappingScrollView
        var hostingController: UIHostingController<Content>?
        var refreshControl: UIRefreshControl?

        init(parent: SnappingScrollView) {
            self.parent = parent
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView.isDragging || scrollView.isDecelerating else { return }

            parent.onScroll(scrollView.contentOffset.y, scrollView)
        }

        @objc func handleRefresh() {
            // 햅틱 피드백
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()

            parent.onRefresh?()

            // 0.7초 후 새로고침 종료 (UX 개선)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                self?.refreshControl?.endRefreshing()
            }
        }
    }
}

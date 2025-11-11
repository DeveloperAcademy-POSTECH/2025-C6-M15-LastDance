//
//  ScrollViewObserver.swift
//  LastDance
//
//  Created by 배현진 on 11/11/25.
//

import SwiftUI

// MARK: - ScrollViewObserver
struct ScrollViewObserver<Content: View>: UIViewRepresentable {
    let content: Content
    @Binding var scrollOffset: CGFloat
    
    init(scrollOffset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        _scrollOffset = scrollOffset
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
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(scrollOffset: $scrollOffset)
    }
    class Coordinator: NSObject, UIScrollViewDelegate {
        @Binding var scrollOffset: CGFloat
        var hostingController: UIHostingController<Content>?
        
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

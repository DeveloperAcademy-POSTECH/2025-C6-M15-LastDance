//
//  CustomBottomSheet.swift
//  LastDance
//
//  Created by 아우신얀 on 10/15/25.
//

import SwiftUI

// MARK: CustomBottomSheet

/// 커스텀 공통 바텀 시트 틀
public struct CustomBottomSheet<Content>: View where Content: View {
    @Binding public var isPresented: Bool
    public var height: CGFloat
    public var content: Content

    @GestureState private var translation: CGFloat = .zero

    public init(_ isPresented: Binding<Bool>, height: CGFloat, content: () -> Content) {
        _isPresented = isPresented
        self.height = height
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: .zero) {
            RoundedRectangle(cornerRadius: 20)
                .fill(LDColor.color6)
                .frame(height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 5)
                )

            self.content
                .frame(height: self.height)
        }
        .frame(height: height + 30)
        .background(
            Rectangle()
                .fill(LDColor.color6)
                .cornerRadius(20, corners: .topLeft)
                .cornerRadius(20, corners: .topRight)
                .edgesIgnoringSafeArea([.bottom, .horizontal])
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .offset(y: translation)
        .gesture(
            DragGesture()
                .updating($translation) { value, state, _ in
                    if value.translation.height >= 0 {
                        let translation = min(self.height, max(-self.height, value.translation.height))
                        state = translation
                    }
                }
                .onEnded { value in
                    if value.translation.height >= height / 3 {
                        self.isPresented = false
                    }
                }
        )
    }
}

// MARK: RoundedCorner

public struct RoundedCorner: Shape {
    public var radius: CGFloat = .infinity
    public var corners: UIRectCorner = .allCorners

    public init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect, byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: 해당 파일에서만 사용되는 extension

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

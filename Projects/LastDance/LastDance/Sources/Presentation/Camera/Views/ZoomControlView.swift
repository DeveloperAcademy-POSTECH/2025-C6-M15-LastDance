//
//  ZoomControlView.swift
//  LastDance
//
//  Created by 배현진 on 10/13/25.
//

import SwiftUI

/// 카메라 줌 기능 컨트롤 뷰
struct ZoomControlView: View {
    @ObservedObject var viewModel: CameraViewModel
    @State private var isDragging = false
    @State private var dragStartScale: CGFloat = 1.0
    @GestureState private var dragTranslation: CGSize = .zero

    // 프리셋/활성 범위 정의
    private let zoomRanges: [ZoomRange] = CameraConstants.zoomRanges.map {
        ZoomRange(label: $0.label, min: $0.min, max: $0.max, preset: $0.preset)
    }

    var body: some View {
        HStack(spacing: Layout.indicatorSpacing) {
            ForEach(Array(zoomRanges.enumerated()), id: \.offset) { _, range in
                let config = range.buttonConfiguration(for: viewModel.zoomScale)
                ZoomCircleButton(
                    text: config.text,
                    isActive: config.isActive,
                    diameter: config.diameter
                )
                .onTapGesture {
                    guard !range.isActive(viewModel.zoomScale) else { return }
                    withAnimation(.easeInOut(duration: Layout.animationDuration)) {
                        viewModel.selectZoomScale(range.preset, animated: false)
                    }
                }
            }
        }
        .padding(.all, Layout.indicatorPadding)
        .background(Color.black.opacity(Layout.indicatorBackgroundOpacity))
        .clipShape(Capsule())
        .gesture(dragGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    dragStartScale = viewModel.zoomScale
                }
                // 전체 0.5~2.0 범위를 약 200pt로 매핑
                let sensitivity = (viewModel.maxZoomScale - viewModel.minZoomScale) / 200.0
                let next = dragStartScale + value.translation.width * sensitivity
                viewModel.selectZoomScale(next, animated: true)
            }
            .onEnded { _ in
                isDragging = false
                viewModel.endZoomInteraction()
            }
    }
}

// MARK: - Circle Button

private struct ZoomCircleButton: View {
    let text: String
    let isActive: Bool
    let diameter: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .minimumScaleFactor(0.7)  // "1.8x" 같은 텍스트도 원 안에 안전하게
            .lineLimit(1)
            .foregroundColor(isActive ? .yellow : LDColor.color6)
            .frame(width: diameter, height: diameter)
            .background(
                Circle().fill(isActive ? LDColor.color6.opacity(0.20) : .clear)
            )
            .overlay(
                Circle().stroke(LDColor.color6.opacity(isActive ? 0.25 : 0.15), lineWidth: 0.5)
            )
            .animation(.easeInOut(duration: 0.15), value: isActive)
            .contentShape(Circle())
    }
}

// MARK: - Range/Config

private struct ZoomRange {
    let label: String
    let min: CGFloat
    let max: CGFloat
    let preset: CGFloat

    private let activeDiameter: CGFloat = Layout.circleActiveDiameter
    private let inactiveDiameter: CGFloat = Layout.circleInactiveDiameter

    func isActive(_ current: CGFloat) -> Bool {
        current >= min && current < max
    }

    func buttonConfiguration(for current: CGFloat)
        -> (text: String, diameter: CGFloat, isActive: Bool)
    {
        let active = isActive(current)
        let text = active ? formatted(current) : label
        let diameter = active ? activeDiameter : inactiveDiameter
        return (text, diameter, active)
    }

    private func formatted(_ value: CGFloat) -> String {
        if abs(value - 1.0) < 0.04 { return "1x" }
        return String(format: "%.1fx", value)
    }
}

// MARK: - Layout
private enum Layout {
    static let indicatorSpacing: CGFloat = CameraConstants.indicatorSpacing
    static let indicatorPadding: CGFloat = CameraConstants.indicatorPadding
    static let indicatorBackgroundOpacity: CGFloat = CameraConstants.indicatorBackgroundOpacity
    static let animationDuration: CGFloat = CameraConstants.animationDuration
    static let circleInactiveDiameter: CGFloat = CameraConstants.circleInactiveDiameter
    static let circleActiveDiameter: CGFloat = CameraConstants.circleActiveDiameter
}

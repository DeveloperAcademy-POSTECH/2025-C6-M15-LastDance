//
//  ShimmerUIView.swift
//  LastDance
//
//  Created by 배현진 on 11/26/25.
//

import SwiftUI

// UIKit 쪽 실제 레이어 뷰
final class ShimmerUIView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.10).cgColor,
            // 중앙: 살짝 시안/민트톤을 섞은 강한 하이라이트
            UIColor(
                red: 0.80,
                green: 0.95,
                blue: 1.00,
                alpha: 0.55
            ).cgColor,
            UIColor.white.withAlphaComponent(0.10).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor,
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0.0, 0.25, 0.5, 0.75, 1.0]

        layer.addSublayer(gradientLayer)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = bounds.width
        let height = bounds.height
        let diag = sqrt(width * width + height * height)

        gradientLayer.frame = CGRect(
            x: -diag,
            y: -diag,
            width: diag * 3,
            height: diag * 3
        )
        gradientLayer.transform = CATransform3DMakeRotation(.pi / 6, 0, 0, 1)

        // 애니메이션이 이미 있으면 중복 추가하지 않음
        if gradientLayer.animation(forKey: "shimmerMove") == nil {
            let anim = CABasicAnimation(keyPath: "position.x")

            anim.fromValue = gradientLayer.position.x - diag
            anim.toValue = gradientLayer.position.x + diag
            anim.duration = 1.3
            anim.repeatCount = .infinity
            anim.autoreverses = true
            anim.isRemovedOnCompletion = false

            gradientLayer.add(anim, forKey: "shimmerMove")
        }
    }
}

// SwiftUI에서 쓸 수 있게 래핑
struct ShimmerLayerView: UIViewRepresentable {
    func makeUIView(context: Context) -> ShimmerUIView {
        ShimmerUIView()
    }

    func updateUIView(_ uiView: ShimmerUIView, context: Context) {
        // 별도 업데이트 필요 없음
    }
}

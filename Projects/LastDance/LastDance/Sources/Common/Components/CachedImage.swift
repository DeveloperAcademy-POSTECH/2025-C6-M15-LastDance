//
//  CachedImage.swift
//  LastDance
//
//  Created by 신얀 on 11/06/25.
//

import Kingfisher
import SwiftUI

/// Kingfisher를 활용한 캐시 최적화 이미지 뷰
/// - 캐시 우선 전략: Kingfisher가 자동으로 메모리→디스크→네트워크 순서로 확인
/// - 다운샘플링: 메모리 효율적인 이미지 처리
/// - 캐시 만료: 메모리 5분, 디스크 7일
struct CachedImage: View {
    let imageURL: String?
    private let targetSize: CGSize?

    init(_ imageURL: String?, targetSize: CGSize? = nil) {
        self.imageURL = imageURL
        self.targetSize = targetSize
    }

    var body: some View {
        if let targetSize = targetSize {
            contentView(size: targetSize)
        } else {
            GeometryReader { geometry in
                contentView(size: geometry.size)
            }
        }
    }

    @ViewBuilder
    private func contentView(size: CGSize) -> some View {
        Group {
            if let imageURL = imageURL, imageURL.hasPrefix("http") {
                // 실제 URL인 경우 - Kingfisher가 자동으로 캐시 우선 처리
                KFImage(URL(string: imageURL))
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.8)
                            )
                    }
                    .setProcessor(createProcessor(for: size))
                    .onFailure { error in
                        Log.fault("❌ Image loading failed: \(error.localizedDescription)")
                    }
                    .onSuccess { result in
                        Log.info("✅ Image loaded from: \(result.cacheType)")
                    }
                    .cacheOriginalImage() // 원본 이미지 캐싱
                    .diskCacheExpiration(.days(7)) // 7일간 디스크 캐시
                    .memoryCacheExpiration(.seconds(300)) // 5분간 메모리 캐시
                    .loadDiskFileSynchronously() // 디스크 캐시 동기 로딩으로 빠른 표시
                    .fade(duration: 0.25)
                    .resizable()

            } else if let imageName = imageURL {
                // Mock 데이터 또는 로컬 이미지
                if UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                } else {
                    // Mock 이미지가 없는 경우
                    Image(systemName: "photo.artframe")
                        .foregroundColor(.gray)
                }
            } else {
                // imageURL이 없는 경우
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
        }
    }

    /// 다운샘플링 프로세서 생성
    /// - Parameter size: 타겟 사이즈 (메모리 최적화를 위해 필요한 크기만큼만 로드)
    private func createProcessor(for size: CGSize) -> ImageProcessor {
        let scaleFactor = UIScreen.main.scale
        let pixelSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // 다운샘플링만 적용
        return DownsamplingImageProcessor(size: pixelSize)
    }
}

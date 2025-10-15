//
//  UIImage.swift
//  LastDance
//
//  Created by 배현진 on 10/09/25.
//

import CoreMedia
import UIKit

extension UIImage {
    /// 원하는 종횡비(가로/세로)에 맞춰 중앙 크롭 (AspectFill의 보이는 범위를 복원)
    func cropped(toAspect targetAspect: CGFloat) -> UIImage {
        let imgW = size.width, imgH = size.height
        let imgAspect = imgW / imgH
        var crop: CGRect

        if imgAspect > targetAspect {
            // 더 넓은 경우에 좌우 자르기
            let newW = imgH * targetAspect
            crop = CGRect(
                x: (imgW - newW) * 0.5,
                y: 0,
                width: newW,
                height: imgH
            )
        } else {
            // 더 좁은 경우에 상하 자르기
            let newH = imgW / targetAspect
            crop = CGRect(
                x: 0,
                y: (imgH - newH) * 0.5,
                width: imgW,
                height: newH
            )
        }

        let scale = self.scale
        guard let croppedImage = self.cgImage?.cropping(to: CGRect(
            x: crop.origin.x * scale,
            y: crop.origin.y * scale,
            width: crop.size.width * scale,
            height: crop.size.height * scale))
        else { return self }
        return UIImage(
            cgImage: croppedImage,
            scale: self.scale,
            orientation: self.imageOrientation
        )
    }
    
    /// SampleBuffer를 UIImage로 변환
    static func from(sampleBuffer: CMSampleBuffer,
                     orientation: UIImage.Orientation = .right) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let ctx = CIContext()
        guard let cgImage = ctx.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
    }
}

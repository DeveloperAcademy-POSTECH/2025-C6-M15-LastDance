//
//  ArchivingViewModel.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import Moya
import SwiftUI

@MainActor
final class ArchivingViewModel: ObservableObject {
    
    private let visitorService = VisitorAPIService()
    private let artistService = ArtistAPIService()

    /// 추가 버튼 탭
    func tapAddButton() {
        // TODO: 전시 추가 또는 다음 화면으로 네비게이션
    }
    
    func fetchAllArtists(onComplete: (() -> Void)? = nil) {
        artistService.getArtists { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    Log.info("Get Artists success. count=\(list.count)")
                case .failure(let error):
                    if let moyaError = error as? MoyaError,
                       let data = moyaError.response?.data,
                       let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                        let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                        Log.warning("Get Artist validation: \(messages)")
                    } else {
                        Log.error("Get Artist failed: \(error)")
                    }
                }
                onComplete?()
            }
        }
    }
}

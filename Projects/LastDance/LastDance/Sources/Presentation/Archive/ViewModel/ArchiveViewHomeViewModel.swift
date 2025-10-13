//
//  ArchiveViewHomeViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftUI
import SwiftData

@MainActor
final class ArchiveViewHomeViewModel: ObservableObject {
    @Published var currentExhibition: Exhibition?
    @Published var visitDate: Date?
    @Published var isLoading = false
    
    private let swiftDataManager = SwiftDataManager.shared
    
    init() {
        loadCurrentExhibition()
    }
    
    // MARK: - Public Methods
    
    func loadCurrentExhibition() {
        isLoading = true
        
        Task {
            do {
                let exhibition = try await fetchCurrentExhibition()
                await MainActor.run {
                    self.currentExhibition = exhibition
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
                Log.error("Failed to load current exhibition: \(error)")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var exhibitionTitle: String {
        currentExhibition?.title ?? "전시명"
    }
    
    var visitDateString: String {
        guard let visitDate = visitDate else {
            return "관람 일자"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: visitDate)
    }
    
    var hasExhibition: Bool {
        currentExhibition != nil
    }
    
    var posterImageName: String? {
        currentExhibition?.coverImageName
    }
    
    // MARK: - Private Methods
    
    private func fetchCurrentExhibition() async throws -> Exhibition? {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ArchiveViewHomeViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
        }
        
        let context = container.mainContext
        let descriptor = FetchDescriptor<Exhibition>()
        let exhibitions = try context.fetch(descriptor)
        
        // 현재 진행 중인 전시 찾기 (임시로 첫 번째 전시 반환)
        return exhibitions.first
    }
}


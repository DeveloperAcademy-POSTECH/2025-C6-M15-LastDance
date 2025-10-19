//
//  ArchiveHomeViewModel.swift
//  LastDance
//
//  Created by 광로 on 10/11/25.
//

import SwiftUI
import SwiftData

@MainActor
final class ArchiveHomeViewModel: ObservableObject {
    @Published private(set) var exhibitions: [Exhibition] = []
    @Published var isLoading = false
    
    private let swiftDataManager = SwiftDataManager.shared
    
    init() {
        loadExhibitions()
    }
    
    func loadExhibitions() {
        isLoading = true
        do {
            self.exhibitions = try fetchExhibitions()
        } catch {
            Log.error("Failed to load exhibitions: \(error)")
        }
        self.isLoading = false
    }
    
    var hasExhibitions: Bool {
        !exhibitions.isEmpty
    }
    
    var exhibitionTitle: String {        return exhibitions.first?.title ?? "전시 정보 없음"
    }
    
    var visitDateString: String {
        guard let firstExhibition = exhibitions.first else { 
            return "관람 일자 없음" 
        }
        return Date.formatDisplayDate(from: firstExhibition.startDate)
    }
    
    func dateString(for exhibition: Exhibition) -> String {
        return Date.formatDisplayDate(from: exhibition.startDate)
    }
    
    private func fetchExhibitions() throws -> [Exhibition] {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ArchiveHomeViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
        }
        
        let context = container.mainContext
        let descriptor = FetchDescriptor<Exhibition>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
}


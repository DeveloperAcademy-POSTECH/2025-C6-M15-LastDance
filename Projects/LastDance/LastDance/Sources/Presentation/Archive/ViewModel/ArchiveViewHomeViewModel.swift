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
    @Published private(set) var exhibitions: [Exhibition] = []
    @Published var isLoading = false
    
    private let swiftDataManager = SwiftDataManager.shared
    
    init() {
        loadExhibitions()
    }
    
    func loadExhibitions() {
        isLoading = true
        Task {
            do {
                self.exhibitions = try await fetchExhibitions()
            } catch {
                Log.error("Failed to load exhibitions: \(error)")
            }
            self.isLoading = false
        }
    }
    
    var hasExhibitions: Bool {
        !exhibitions.isEmpty
    }
    
    func dateString(for exhibition: Exhibition) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        return formatter.string(from: exhibition.startDate)
    }
    
    private func fetchExhibitions() async throws -> [Exhibition] {
        guard let container = swiftDataManager.container else {
            throw NSError(domain: "ArchiveViewHomeViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Container not available"])
        }
        
        let context = container.mainContext
        let descriptor = FetchDescriptor<Exhibition>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
}


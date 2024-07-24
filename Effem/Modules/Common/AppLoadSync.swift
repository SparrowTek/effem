//
//  AppLoadSync.swift
//  Effem
//
//  Created by Thomas Rademaker on 7/20/24.
//

import SwiftUI
import PodcastIndexKit

fileprivate struct SyncAppLoad: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    func body(content: Content) -> some View {
        content
            .task { await loadData() }
    }
    
    private func loadData() async {
        guard let categories = try? await CategoriesService().list(), let feeds = categories.feeds else { return }
        
        for category in feeds {
            guard let id = category.id, let name = category.name else { continue }
            let fmCategory = FMCategory(id: id, name: name)
            modelContext.insert(fmCategory)
        }
        
        try? modelContext.save()
    }
}

extension View {
    func appLoadSync() -> some View {
        modifier(SyncAppLoad())
    }
}

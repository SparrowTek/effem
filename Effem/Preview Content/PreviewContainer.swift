//
//  PreviewContainer.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/2/23.
//

import Foundation
import SwiftData
import SwiftUI
import PodcastIndexKit

struct SampleDataPodcast: PreviewModifier {
    
    static func makeSharedContext() throws -> ModelContainer {
        let container = try ModelContainer(for: FMPodcast.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        if let podcastResponse: PodcastResponse = object(resourceName: "podcastresponse"),
           let podcast = podcastResponse.feed {
            container.mainContext.insert(FMPodcast(podcast: podcast))
        }
        
        try container.mainContext.save()
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

struct SampleDataEpisodes: PreviewModifier {
    
    static func makeSharedContext() throws -> ModelContainer {
        let container = try ModelContainer(for: FMPodcast.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        if let episodes: EpisodeArrayResponse = object(resourceName: "episodeArrayResponse"),
           let episodes = episodes.items {
            for episode in episodes {
                container.mainContext.insert(FMEpisode(episode: episode))
            }
        }
        
        try container.mainContext.save()
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

struct SampleDataCategories: PreviewModifier {
    
    static func makeSharedContext() throws -> ModelContainer {
        let container = try ModelContainer(for: FMPodcast.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        container.mainContext.insert(FMCategory(id: 0, name: "All"))
        
        if let categories: CategoriesResponse = object(resourceName: "categories"),
           let feeds = categories.feeds {
            for category in feeds {
                guard let id = category.id, let name = category.name else { continue }
                container.mainContext.insert(FMCategory(id: id, name: name))
            }
        }
        
        try container.mainContext.save()
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var samplePodcast: Self = .modifier(SampleDataPodcast())
    @MainActor static var sampleEpisodes: Self = .modifier(SampleDataEpisodes())
    @MainActor static var sampleCategories: Self = .modifier(SampleDataCategories())
}

fileprivate func object<c: Codable>(resourceName: String) -> c? {
    guard let file = Bundle.main.url(forResource: resourceName, withExtension: "json"),
          let data = try? Data(contentsOf: file) else { return nil }
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try? decoder.decode(c.self, from: data)
}

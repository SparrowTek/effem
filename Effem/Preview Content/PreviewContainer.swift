//
//  PreviewContainer.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/2/23.
//

import Foundation
import SwiftData
import PodcastIndexKit

#if DEBUG
@MainActor
public let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: FMPodcast.self, FMEpisode.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        if let podcastResponse: PodcastResponse = object(resourceName: "podcastresponse"),
           let podcast = podcastResponse.feed {
            container.mainContext.insert(FMPodcast(podcast: podcast))
        }
        
        if let episodes: EpisodeArrayResponse = object(resourceName: "episodeArrayResponse"),
           let episodes = episodes.items {
            for episode in episodes {
                container.mainContext.insert(FMEpisode(episode: episode))
            }
        }
        
        if let categories: CategoriesResponse = object(resourceName: "categories"), let feeds = categories.feeds {
            for category in feeds {
                guard let id = category.id, let name = category.name else { continue }
                let fmCategory = FMCategory(id: id, name: name)
                container.mainContext.insert(fmCategory)
            }
        }
        
        try container.mainContext.save()
        
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

fileprivate func object<c: Codable>(resourceName: String) -> c? {
    guard let file = Bundle.main.url(forResource: resourceName, withExtension: "json"),
          let data = try? Data(contentsOf: file) else { return nil }
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try? decoder.decode(c.self, from: data)
}

#endif

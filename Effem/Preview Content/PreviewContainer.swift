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
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        print("YO 1")
        
        if let podcastFile = Bundle.main.url(forResource: "podcastresponse", withExtension: "json") {
            print("YO 2")
            let data = try Data(contentsOf: podcastFile)
            let podcastResponse = try decoder.decode(PodcastResponse.self, from: data)
            
            if let podcast = podcastResponse.feed {
                print("podcast saved")
                container.mainContext.insert(FMPodcast(podcast: podcast))
            }
        }
        
        if let episodesFile = Bundle.main.url(forResource: "episodeArrayResponse", withExtension: "json") {
            let data = try Data(contentsOf: episodesFile)
            let episodes = try decoder.decode(EpisodeArrayResponse.self, from: data)
            
            if let episodes = episodes.items {
                for episode in episodes {
                    container.mainContext.insert(FMEpisode(episode: episode))
                }
            }
        }
        
        try container.mainContext.save()
        
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
#endif

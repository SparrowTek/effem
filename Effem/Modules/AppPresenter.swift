//
//  AppPresenter.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import SwiftUI
import SwiftData
import PodcastIndexKit

struct AppPresenter: View {
    @Environment(AppState.self) private var state
    @Environment(PodcastIndexKit.self) private var podcastIndex
    @Environment(\.modelContext) private var context
    
    var body: some View {
        switch state.route {
        case .main:
            MainTabBar()
                .task { await loadTestData() }
        }
    }
    
    private func loadTestData() async {
        do {
            let episodeResponse = try await podcastIndex.episodesService.episodes(byFeedID: "41504")
            
            if let episodes = episodeResponse.items {
                for episode in episodes {
                    context.insert(FMEpisode(episode: episode))
                }
            }
            
            if episodeResponse.items?.count ?? 0 > 0 {
                let episode = episodeResponse.items?[0]
                await MediaPlaybackManager.shared.setEpisode(episode)
                
                let podcastResponse = try await podcastIndex.podcastsService.podcast(byFeedId: episode?.feedId ?? 0)
                await MediaPlaybackManager.shared.setPodcast(podcastResponse.feed)
                
                if let podcast = podcastResponse.feed {
                    context.insert(FMPodcast(podcast: podcast))
                }
                
                print("EPISODE: \(String(describing: episode))")
            }
        } catch {
            print("PODCAST ERROR: \(error)")
        }
    }
}

#Preview {
    AppPresenter()
        .environment(AppState())
        .environment(MediaPlaybackManager.shared)
        .environment(PodcastIndexKit())
    #if DEBUG
        .modelContainer(previewContainer)
    #endif
}

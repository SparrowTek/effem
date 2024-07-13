//
//  UnsubscribedPodcastView.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/11/23.
//

import SwiftUI
import SwiftData
import PodcastIndexKit

@MainActor
struct UnsubscribedPodcastView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var subscribeInProgress = false
    @State private var subscribeTrigger = PlainTaskTrigger()
    @Query private var podcasts: [FMPodcast]
    
    let podcast: Podcast
    
    private var isSubscribed: Bool {
        let guid = podcast.podcastGuid
        guard let podcastsMatchingFilter = try? podcasts.filter(#Predicate { $0.podcastGuid == guid }) else { return false }
        return podcastsMatchingFilter.count > 0
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                CommonImage(image: .url(url: podcast.artwork, sfSymbol: "photo"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .scaledToFit()
                    .frame(width: 100)
                    .frame(height: 100)
                
                VStack(alignment: .leading) {
                    Text(podcast.title ?? "")
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                        .setForegroundStyle()
                    
                    Button(action: triggerSubscibe) {
                        Group {
                            if subscribeInProgress {
                                ProgressView()
                            } else {
                                Text(isSubscribed ? "unsubscribe" : "subscribe")
                                    .foregroundStyle(.primaryWhite)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(subscribeInProgress)
                }
                
                Spacer()
            }
            .padding()
            
            Text(podcast.podcastDescription ?? "")
                .setForegroundStyle()
                .padding(.horizontal)
            
            Divider()
            
            EpisodesScrollView(podcastGUID: podcast.podcastGuid)
        }
        .navigationTitle("new podcast")
        .navigationBarTitleDisplayMode(.inline)
        .commonView()
        .task($subscribeTrigger) { await subscribe() }
    }
    
    private func triggerSubscibe() {
        subscribeTrigger.trigger()
    }
    
    private func subscribe() async {
        subscribeInProgress = true
        
        if isSubscribed {
            if let subscribedPodcast = try? podcasts.filter(#Predicate { $0.podcastGuid == podcast.podcastGuid }).first {
                modelContext.delete(subscribedPodcast)
            } else {
                // TODO: handle error
                subscribeInProgress = false
            }
        } else {
            let fmPodcast = FMPodcast(podcast: podcast)
            modelContext.insert(fmPodcast)
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        subscribeInProgress = false
    }
}

@MainActor
fileprivate struct EpisodesScrollView: View {
    var podcastGUID: String?
    @State private var episodes: [Episode] = []
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if episodes.isEmpty {
                    ProgressView()
                } else {
                    ForEach(episodes) {
                        EpisodeCell(episode: $0)
                    }
                }
            }
        }
        .task { await getEpisodes() }
    }
    
    private func getEpisodes() async {
        guard let episodes = try? await EpisodesService().episodes(byPodcastGUID: podcastGUID ?? "").items else { return }
        self.episodes = episodes
    }
}

@MainActor
fileprivate struct EpisodeCell: View {
    @Environment(\.modelContext) private var modelContext
    @State private var downloadTrigger = PlainTaskTrigger()
    var episode: Episode
    
    var body: some View {
        HStack(spacing: 0) {
            Text(episode.title ?? "")
            Spacer()
            
            Button("", systemImage: "play.circle", action: play)
                .imageScale(.large)
            Button("", systemImage: "arrow.down.circle", action: triggerDownload)
                .imageScale(.large)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .task($downloadTrigger) { await download() }
    }
    
    private func play() {
        
    }
    
    private func triggerDownload() {
        downloadTrigger.trigger()
    }
    
    private func download() async {
        guard let guid = episode.guid else { return }
        guard let episode = try? await EpisodesService().episodes(byGUID: guid).episode else { return }
        let fmEpisode = FMEpisode(episode: episode)
        modelContext.insert(fmEpisode)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        UnsubscribedPodcastView(podcast: Podcast.preview)
            .setupPodcastIndexKit()
            .modelContainer(previewContainer)
    }
}
#endif

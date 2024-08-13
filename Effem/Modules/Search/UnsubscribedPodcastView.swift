//
//  UnsubscribedPodcastView.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/11/23.
//

import SwiftUI
import SwiftData
import PodcastIndexKit

struct UnsubscribedPodcastView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var subscribeInProgress = false
    @State private var subscribeTrigger = PlainTaskTrigger()
    @Query private var podcasts: [FMPodcast]
    
    let podcast: Podcast
    
    private var isSubscribed: Bool {
        let id = podcast.id
        guard let podcastsMatchingFilter = try? podcasts.filter(#Predicate { $0.id == id }) else { return false }
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
            
            EpisodesScrollView(podcastFeedID: podcast.id)
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

fileprivate struct EpisodesScrollView: View {
    var podcastFeedID: Int?
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
        guard let episodes = try? await EpisodesService().episodes(byFeedID: "\(podcastFeedID ?? 0)").items else { return }
        self.episodes = episodes
    }
}

fileprivate struct EpisodeCell: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DownloadManager.self) private var downloadManager
    var episode: Episode
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text(episode.title ?? "")
                Spacer()
                
                Button("", systemImage: "play.circle", action: play)
                    .imageScale(.large)
                Button("", systemImage: "arrow.down.circle", action: download)
                    .imageScale(.large)
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.leading)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func play() {
        #warning("play can only work and be displayed as an option if the episode is already downloaded")
    }
    
    private func download() {
        downloadManager.downloadEpisode(episode)
    }
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.modelContext) var context
    
    NavigationStack {
        UnsubscribedPodcastView(podcast: Podcast.preview)
            .setupPodcastIndexKit()
            .modelContainer(previewContainer)
            .environment(DownloadManager(modelContainer: context.container))
    }
}
#endif

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
            
            List {
                Text("EPISODE 1")
                Text("EPISODE 2")
            }
            .listStyle(.plain)
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
            }
        } else {
            let fmPodcast = FMPodcast(podcast: podcast)
            modelContext.insert(fmPodcast)
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        subscribeInProgress = false
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        UnsubscribedPodcastView(podcast: Podcast.preview)
            .modelContainer(previewContainer)
    }
}
#endif

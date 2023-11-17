//
//  UnsubscribedPodcastView.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/11/23.
//

import SwiftUI
import PodcastIndexKit

struct UnsubscribedPodcastView: View {
    @Environment(\.modelContext) private var modelContext
    let podcast: Podcast
    
    var body: some View {
        VStack {
            HStack {
                CommonImage(image: .url(url: podcast.artwork, sfSymbol: "photo"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .scaledToFit()
                    .frame(width: 150)
                    .frame(height: 150)
            
                VStack(alignment: .leading) {
                    Text(podcast.title ?? "")
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                    
                    Button("subscribe", action: subscribe)
                        .buttonStyle(.borderedProminent)
                }
                
                Spacer()
            }
            .padding()
            
            Text(podcast.podcastDescription ?? "")
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
    }
    
    private func subscribe() {
        let fmPodcast = FMPodcast(podcast: podcast)
        modelContext.insert(fmPodcast)
    }
}

//#Preview {
//    NavigationStack {
//        UnsubscribedPodcastView(artwork: "https://noagendaassets.com/enc/1698943491.532_na-1604-lit.png", title: "No Agenda", description: "The no agenda show by John C Devorak and Adam Curry. Something blah blah blah")
//    }
//}

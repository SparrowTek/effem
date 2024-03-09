//
//  PodcastIndexInfoView.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/11/23.
//

import SwiftUI
import PodcastIndexKit

@MainActor
struct PodcastIndexInfoView: View {
    @Environment(PodcastIndexKit.self) private var podcastIndex
    @State private var stats: StatProperties?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Effem is powered by Podcasting 2.0 and the [Podcast Index](https://podcastindex.org)")
                .font(.title2)
                .padding(.horizontal)
            
            Text("Total Podcasts in the Index...")
                .font(.title2)
                .padding()
            
            if let stats, let countTotal = stats.feedCountTotal {
                Text("\(countTotal)")
                    .font(.largeTitle)
                    .foregroundStyle(.podcastIndexRed)
                    .padding(.horizontal)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.podcastIndexRed)
                    .padding(.horizontal)
            }
        }
        .task { await getStats() }
    }
    
    private func getStats() async {
        stats = try? await podcastIndex.statsService.current().stats
        
    }
}

#Preview {
    NavigationStack {
        List {
            Text("Search View")
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .searchable(text: .constant(""), prompt: "shows, episidoes, and more")
        .navigationTitle("Search")
            .sheet(isPresented: .constant(true)) {
                PodcastIndexInfoView()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium])
                    .environment(PodcastIndexKit())
            }
    }
}

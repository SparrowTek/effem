//
//  LibraryView.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import SwiftUI
import SwiftData
import NukeUI

@MainActor
struct LibraryPresenter: View {
    @Environment(LibraryState.self) private var state: LibraryState
    
    var body: some View {
        NavigationStack {
            LibraryView()
        }
    }
}

@MainActor
struct LibraryView: View {
    private var tabs: [UnderlinedTab] = [
        .init(id: 0, title: "episodes"),
        .init(id: 1, title: "shows"),
    ]
    
    var body: some View {
        VStack {
            UnderlinedTabView(tabs: tabs, tabViewStyle: .automatic) {
                LibraryEpisodesView()
                    .tag(0)
                
                LibraryShowsView()
                    .tag(1)
            }
        }
        .navBar()
        .commonView()
    }
}

@MainActor
fileprivate struct LibraryEpisodesView: View {
    @Query private var episodes: [FMEpisode]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            ForEach(episodes) {
                LibraryEpisodeCell(episode: $0)
            }
            .onDelete(perform: deleteEpisode)
        }
        .listStyle(.plain)
        .commonView()
    }
    
    private func deleteEpisode(_ indexSet: IndexSet) {
        for item in indexSet {
            modelContext.delete(episodes[item])
        }
    }
}

@MainActor
fileprivate struct LibraryShowsView: View {
    @Query private var podcasts: [FMPodcast]
    
    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(podcasts) {
                    LibraryShowCell(podcast: $0)
                }
            }
            .setForegroundStyle()
        }
        .scrollIndicators(.hidden)
        .commonView()
    }
}

@MainActor
fileprivate struct LibraryShowCell: View {
    var podcast: FMPodcast
    
    var imageURL: String? {
        if let artwork = podcast.artwork {
            return artwork
        } else {
            return podcast.image
        }
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                CommonImage(image: .url(url: imageURL, sfSymbol: "photo"))
                    .frame(width: 75, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                ThemedCircle()
                    .frame(width: 20)
                    .overlay(
                        Text("1")
                            .adaptiveFontWithThemeColorBackground()
                    )
                    .offset(x: 12, y: -12)
            }
            .frame(width: 100, height: 100)
            
            Text(podcast.title ?? "")
                .lineLimit(2, reservesSpace: true)
        }
    }
}

@MainActor
fileprivate struct LibraryEpisodeCell: View {
    var episode: FMEpisode
    
    var imageURL: String? {
        if let image = episode.episode.image {
            return image
        } else {
            return episode.episode.feedImage
        }
    }
    
    var body: some View {
        HStack {
            CommonImage(image: .url(url: imageURL, sfSymbol: "photo"))
                .frame(width: 75, height: 75)
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
            
            VStack(alignment: .leading) {
                Text(episode.episode.title ?? "")
                    .font(.title2)
                Text("TODO: GET AUTHOR")
                    .font(.footnote)
                Spacer()
            }
            .padding(.top)
            
            Spacer()
            
            ThemedCircle()
                .frame(width: 10)
        }
        .listRowBackground(Color.primaryBackground)
        .listRowSeparator(.hidden, edges: .top)
        
    }
}

#Preview {
    LibraryPresenter()
        .environment(AppState())
        .environment(LibraryState(parentState: .init()))
        .environment(MediaPlaybackManager.shared)
        #if DEBUG
        .modelContainer(previewContainer)
        #endif
}

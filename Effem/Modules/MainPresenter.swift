//
//  MainPresenter.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import SwiftUI
import SwiftData

struct MainPresenter: View {
    @Environment(AppState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack {
            LibraryView()
                .playbackBar()
                .setTheme()
                .sheet(item: $state.sheet) {
                    switch $0 {
                    case .nowPlaying:
                        NowPlayingView()
                            .setTheme()
                    case .settings:
                        SettingsPresenter()
                            .environment(state.settingsState)
                            .setTheme()
                    case .downloads:
                        Text("DOWNLOADS")
                            .presentationDragIndicator(.visible)
                    case .search:
                        SearchPresenter()
                            .environment(state.searchState)
                            .setTheme()
                    }
                }
        }
    }
}

struct LibraryView: View {
    @Environment(AppState.self) private var state
    @Environment(DownloadManager.self) private var downloadManager
    
    var body: some View {
        VStack {
            UnderlinedTabView(tabViewStyle: .automatic) {
                LibraryEpisodesView(underlineTabState: state.underlineTabState)
                    .tag(0)
                
                LibraryShowsView()
                    .tag(1)
            }
        }
        .fullScreenColorView()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: openSettings) {
                    Image(systemName: "slider.horizontal.3")
                }
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                if downloadManager.hasDownloadsInProgress {
                    Button("", systemImage: "icloud.and.arrow.down", action: openDownloads)
                }
                
                Button("", systemImage: "plus", action: addPlaylist)
                Button("", systemImage: "magnifyingglass", action: openSearch)
            }
        }
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
    }
    
    private func openSettings() {
        state.openSettings()
    }
    
    private func openDownloads() {
        state.openDownloads()
    }
    
    private func openSearch() {
        state.openSearch()
    }
    
    private func addPlaylist() {
        
    }
}

fileprivate struct LibraryEpisodesView: View {
    @Query private var episodes: [FMEpisode]
    @Environment(\.modelContext) private var modelContext
    @Bindable var underlineTabState: UnderlinedTabState
    
    var body: some View {
        ZStack {
            if episodes.isEmpty {
                VStack {
                    ContentUnavailableView("no episodes available", systemImage: "waveform.slash", description: Text("add episodes from you podcast list"))
                    Button("add episodes", action: addEpisodes)
                        .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    ForEach(episodes) {
                        LibraryEpisodeCell(episode: $0)
                    }
                    .onDelete(perform: deleteEpisode)
                }
                .listStyle(.plain)
            }
        }
        .fullScreenColorView()
    }
    
    private func addEpisodes() {
        withAnimation { underlineTabState.selectedTabIndex = 1 }
    }
    
    private func deleteEpisode(_ indexSet: IndexSet) {
        for item in indexSet {
            modelContext.delete(episodes[item])
        }
    }
}

fileprivate struct LibraryShowsView: View {
    @Environment(AppState.self) private var state
    @Query private var podcasts: [FMPodcast]
    
    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
    ]
    
    var body: some View {
        ZStack {
            if podcasts.isEmpty {
                VStack {
                    ContentUnavailableView("no podcasts available", systemImage: "waveform.slash", description: Text("search for podcasts to add to your library"))
                    Button("search for podcasts", action: searchForPodcasts)
                        .buttonStyle(.borderedProminent)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(podcasts) {
                            LibraryShowCell(podcast: $0)
                        }
                    }
                    .setForegroundStyle()
                }
                .scrollIndicators(.hidden)
            }
        }
        .fullScreenColorView()
    }
    
    private func searchForPodcasts() {
        state.sheet = .search
    }
}

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
                CommonImage(image: .url(url: imageURL, placeholder: .sfSymbol("photo")))
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

fileprivate struct LibraryEpisodeCell: View {
    @Environment(MediaPlaybackManager.self) private var mediaPlaybackManager
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
            CommonImage(image: .url(url: imageURL, placeholder: .sfSymbol("photo")))
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
        .contentShape(Rectangle())
        .onTapGesture(perform: playEpisode)
    }
    
    private func playEpisode() {
        mediaPlaybackManager.setEpisode(episode.episode)
    }
}

#if DEBUG
#Preview(traits: .sampleCompositeAll) {
    MainPresenter()
        .setupPodcastIndexKit()
        .environment(AppState())
        .environment(MediaPlaybackManager())
        .setupDownloadManager()
}
#endif

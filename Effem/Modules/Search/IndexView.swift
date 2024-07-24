//
//  IndexView.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import SwiftUI
import PodcastIndexKit

struct IndexPresenter: View {
    @Environment(IndexState.self) private var state: IndexState
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack(path: $state.path) {
            IndexView()
                .navigationDestination(for: Podcast.self) {
                    UnsubscribedPodcastView(podcast: $0)
                }
                .sheet(item: $state.sheet) {
                    switch $0 {
                    case .podcastIndexInfo:
                        PodcastIndexInfoView()
                            .presentationDragIndicator(.visible)
                            .presentationDetents([.medium])
                    }
                }
        }
    }
}

struct IndexView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]
    
    enum Scope: Int, CaseIterable, Identifiable {
        case all
        case title
        case person
        case term
        
        var id: Int { rawValue }
        
        var text: LocalizedStringResource {
            switch self {
            case .all: "all"
            case .title: "title"
            case .person: "person"
            case .term: "term"
            }
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(IndexState.self) private var state: IndexState
    @State private var query = ""
    @State private var scope: Int = Scope.all.rawValue
    @State private var performSearchTrigger = PlainTaskTrigger()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(state.podcasts) {
                    SearchListCell(podcast: $0)
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .padding(.bottom)
        .searchable(text: $query, prompt: "shows, episidoes, and more")
        .searchScopes($scope, activation: .onSearchPresentation) {
            ForEach(Scope.allCases) {
                Text($0.text).tag($0.rawValue)
            }
        }
        .onChange(of: query, triggerPerformSearch)
        .onChange(of: scope, triggerPerformSearch)
        .commonView()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: "questionmark.circle", action: displayPodcastIndexInfo)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismiss() })
            }
        }
        .navigationTitle("Search")
        .task { await getRecentPodcasts() }
        .task($performSearchTrigger) { await performSearch() }
    }
    
    private func triggerPerformSearch() {
        performSearchTrigger.trigger()
    }
    
    private func performSearch() async {
        guard query.count >= 3, let scope = Scope(rawValue: scope) else { return }
        let searchQuery = query
        
        switch scope {
        case .all:
            break
        case .title:
            state.podcasts = (try? await SearchService().search(byTitle: searchQuery).feeds) ?? []
        case .person:
            state.podcasts = (try? await SearchService().search(byPerson: searchQuery).feeds) ?? []
        case .term:
            state.podcasts = (try? await SearchService().search(byTerm: searchQuery).feeds) ?? []
        }
    }
    
    private func displayPodcastIndexInfo() {
        state.sheet = .podcastIndexInfo
    }
    
    private func getRecentPodcasts() async {
        guard state.podcasts.isEmpty else { return }
        guard let episodesArrayResponse = try? await RecentService().recentEpisodes(),
                let items = episodesArrayResponse.items else { return }
        
        let feedIDsArray = items.map { $0.feedId }
        let feedIDs = Set(feedIDsArray)
        
        let podcasts: [Podcast?]? = try? await withThrowingTaskGroup(of: Podcast?.self) { group in
            for feedID in feedIDs {
                if let feedID {
                    group.addTask { return try await PodcastsService().podcast(byFeedId: feedID).feed }
                }
            }
            
            var podcasts: [Podcast?] = []
            
            for try await podcast in group {
                podcasts.append(podcast)
            }
            
            return podcasts
        }
        
        if let podcasts {
            state.podcasts = podcasts.compactMap { $0 }
        }
    }
}

fileprivate struct SearchListCell: View {
    @Environment(IndexState.self) private var state: IndexState
    let podcast: Podcast
    
    var body: some View {
        Button(action: openPodcast) {
            VStack {
                CommonImage(image: .url(url: podcast.artwork, sfSymbol: "photo"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                
                Text(podcast.title ?? "")
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func openPodcast() {
        state.path.append(podcast)
    }
}

#Preview {
    NavigationStack {
        IndexPresenter()
            .setupPodcastIndexKit()
            .environment(IndexState(parentState: .init()))
            .environment(MediaPlaybackManager.shared)
            .environment(AppState())
            .environment(PodcastIndexKit())
    }
}

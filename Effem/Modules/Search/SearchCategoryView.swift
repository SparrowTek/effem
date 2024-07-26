//
//  SearchCategoryView.swift
//  Effem
//
//  Created by Thomas Rademaker on 7/25/24.
//

import SwiftUI
import SwiftData
import PodcastIndexKit


struct SearchCategoryView: View {
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
    
    var category: FMCategory
    @Environment(\.dismiss) private var dismiss
    @Environment(SearchState.self) private var state: SearchState
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
        .searchable(text: $query, prompt: "podcasts, episidoes, and more")
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
                Button("done", action: { dismiss() })
            }
        }
        .navigationTitle(category.name)
        .task { await getPodcastsForCategory() }
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
    
    private func getPodcastsForCategory() async {
        guard state.podcasts.isEmpty else { return }
        guard let podcastArrayResponse = try? await PodcastsService().trendingPodcasts(cat: category.name),
              let podcasts = podcastArrayResponse.feeds else { return }
        state.podcasts = podcasts
    }
}

fileprivate struct SearchListCell: View {
    @Environment(SearchState.self) private var state: SearchState
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
        state.path.append(.podcast(podcast))
    }
}

#Preview {
    SearchCategoryView(category: FMCategory(id: 2, name: "Books"))
        .setupPodcastIndexKit()
        .environment(SearchState(parentState: .init()))
        .environment(MediaPlaybackManager())
        .environment(AppState())
        .environment(PodcastIndexKit())
        #if DEBUG
        .modelContainer(previewContainer)
        #endif
}

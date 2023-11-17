//
//  LibraryView.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import SwiftUI
import SwiftData
import NukeUI

struct LibraryPresenter: View {
    @Environment(LibraryState.self) private var state: LibraryState
    
    var body: some View {
        NavigationStack {
            LibraryView()
        }
    }
}

struct LibraryView: View {
    @State private var searchText = ""
    @Query private var podcasts: [FMPodcast]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            ForEach(podcasts) {
                LibraryPodcastCell(podcast: $0)
            }
            .onDelete(perform: deletePodcast)
        }
        .listStyle(.plain)
        .navBar()
        .commonView()
        .searchable(text: $searchText)
    }
    
    private func deletePodcast(_ indexSet: IndexSet) {
        for item in indexSet {
            let podcast = podcasts[item]
            modelContext.delete(podcast)
        }
    }
}

fileprivate struct LibraryPodcastCell: View {
    var podcast: FMPodcast
    
    var imageURL: String? {
        if let artwork = podcast.artwork {
            return artwork
        } else {
            return podcast.image
        }
    }
    
    var body: some View {
        HStack {
            CommonImage(image: .url(url: imageURL, sfSymbol: "photo"))
                .frame(width: 75, height: 75)
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
            
            VStack(alignment: .leading) {
                Text(podcast.title ?? "")
                    .font(.title2)
                Text(podcast.author ?? "")
                    .font(.footnote)
                Spacer()
            }
            .padding(.top)
            
            Spacer()
            
            Circle()
                .fill(.green)
                .frame(width: 10)
        }
        .listRowBackground(Color.primaryBackground)
        .listRowSeparator(.hidden, edges: .top)
        
    }
}

#Preview {
    NavigationStack {
        LibraryView()
            .environment(AppState())
            .environment(LibraryState(parentState: .init()))
            .environment(MediaPlaybackManager.shared)
            .modelContainer(previewContainer)
    }
}

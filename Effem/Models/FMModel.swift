//
//  FMModel.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/1/23.
//

import SwiftUI
import SwiftData

typealias FMPodcast = FMPodcastSchemaV1.FMPodcast
typealias FMEpisode = FMEpisodeSchemaV1.FMEpisode

@Model
class FMModel {
    init() {}
}

extension FMModel {
    static let schema = SwiftData.Schema([
        FMModel.self,
        FMPodcast.self,
        FMEpisode.self,
    ])
}

struct EffemDataContainerViewModifier: ViewModifier {
    let container: ModelContainer
    
    init(inMemory: Bool) {
        do {
            container = try ModelContainer(for: FMModel.schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: inMemory)])
        } catch {
            fatalError("Failed to create ModelContainer")
        }
    }
    
    func body(content: Content) -> some View {
        content
            .modelContainer(container)
    }
}

//struct ACModelViewModifier: ViewModifier {
//    @Environment(\.modelContext) private var modelContext
//
//    func body(content: Content) -> some View {
//        content.onAppear {
//            DataGeneration.generateAllData(modelContext: modelContext)
//        }
//    }
//}

extension View {
    func setupModel(inMemory: Bool = FMModelOptions.inMemoryPersistence) -> some View {
        modifier(EffemDataContainerViewModifier(inMemory: inMemory))
    }
}


//
//  DownloadManager.swift
//  Effem
//
//  Created by Thomas Rademaker on 7/25/24.
//

import Foundation
import SwiftData
import PodcastIndexKit

@Observable
@MainActor
class DownloadManager {
    var hasDownloadsInProgress = false
    private let modelContainer: ModelContainer

    
    // TODO: figure out how to track downloads in this array and have it update the hasDownloadsInProgress bool
    private var downloads: [Episode] = []
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func downloadEpisode(_ episode: Episode) async throws {
//        defer { downloads.rem }
//        downloads.append(episode)
        guard let guid = episode.guid, let feedID = episode.feedId else { return }
        guard let episode = try await EpisodesService().episodes(byGUID: guid, feedid: "\(feedID)").episode else { return }
        let data = try await DownloadService().downloadEpisode(from: episode.enclosureUrl)
        try await DownloadPersistor(modelContainer: modelContainer).saveEpisode(episode, with: data)
    }
}

@ModelActor
actor DownloadPersistor {
    func saveEpisode(_ episode: Episode, with data: Data) throws {
        let fmEpisode = FMEpisode(episode: episode)
        modelContext.insert(fmEpisode)
        fmEpisode.audioFile = data
        try modelContext.save()
    }
}

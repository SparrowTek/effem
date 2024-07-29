//
//  DownloadManager.swift
//  Effem
//
//  Created by Thomas Rademaker on 7/25/24.
//

import Foundation
import SwiftUI
import SwiftData
import PodcastIndexKit

@Observable
@MainActor
class DownloadManager {
    var hasDownloadsInProgress = false
    private let modelContainer: ModelContainer
    private var inProgressDownloads = [Episode : Task<(), Never>]() {
        didSet { hasDownloadsInProgress != inProgressDownloads.isEmpty }
    }
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    func downloadEpisode(_ episode: Episode) {
        guard inProgressDownloads[episode] == nil else { return }
        
        // REMEMBER - Tasks eat errors
        // Intentionally ignoring errors here. If it fails we'll cache it next time
        let task = Task.detached { [weak self] in
            guard let self, let guid = episode.guid, let feedID = episode.feedId else { return }
            
            do {
                try Task.checkCancellation()
                guard let episode = try await EpisodesService().episodes(byGUID: guid, feedid: "\(feedID)").episode else { return }
                let data = try await DownloadService().downloadEpisode(from: episode.enclosureUrl)
                try await DownloadPersistor(modelContainer: self.modelContainer).saveEpisode(episode, with: data)
            } catch {
                await removeDownloadRequestValue(forKey: episode)
                return
            }
        }
        
        inProgressDownloads[episode] = task
    }
    
    // MARK: in progress downloads
    private func removeDownloadRequestValue(forKey key: Episode) {
        inProgressDownloads.removeValue(forKey: key)
    }
    
    func cancelPrefetch(for episode: Episode) {
        guard let task = inProgressDownloads[episode] else { return }
        task.cancel()
        inProgressDownloads.removeValue(forKey: episode)
    }
    
    func clearCache() {
        inProgressDownloads.values.forEach { $0.cancel() }
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

struct DownloadManagerViewModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    func body(content: Content) -> some View {
        content
            .environment(DownloadManager(modelContainer: modelContext.container))
    }
}

extension View {
    func setupDownloadManager() -> some View {
        modifier(DownloadManagerViewModifier())
    }
}

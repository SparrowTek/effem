//
//  EffemApp.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/8/23.
//

import SwiftUI
import PodcastIndexKit

@main
struct EffemApp: App {
    @State private var podcastIndex = PodcastIndexKit()
    @State private var state = AppState()
    @State private var mediaPlaybackManager = MediaPlaybackManager()
    @State private var downloadManager = DownloadManager()
    
    var body: some Scene {
        WindowGroup {
            AppPresenter()
                .environment(state)
                .environment(podcastIndex)
                .environment(mediaPlaybackManager)
                .environment(downloadManager)
                .setupModel()
                .setTheme()
                .task { await setupPodcastIndexKit() }
        }
    }
    
    private func setupPodcastIndexKit() async {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let apiKey = infoDictionary["PodcastIndexAPIKey"] as? String,
              let apiSecret = infoDictionary["PodcastIndexAPISecret"] as? String,
              let userAgent = infoDictionary["PodcastIndexUserAgent"] as? String else { fatalError("PodcastIndexKit API key, API secret, and User Agent are not properly set in your User.xcconfig file") }
        await PodcastIndexKit.setup(apiKey: apiKey, apiSecret: apiSecret, userAgent: userAgent)
    }
}

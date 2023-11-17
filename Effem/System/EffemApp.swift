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
    
    init() {
        setupPodcastIndexKit()
    }
    
    var body: some Scene {
        WindowGroup {
            AppPresenter()
                .environment(state)
                .environment(podcastIndex)
                .environment(MediaPlaybackManager.shared)
                .setupModel()
        }
    }
    
    private func setupPodcastIndexKit() {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let apiKey = infoDictionary["PodcastIndexAPIKey"] as? String,
              let apiSecret = infoDictionary["PodcastIndexAPISecret"] as? String,
              let userAgent = infoDictionary["PodcastIndexUserAgent"] as? String else { fatalError("PodcastIndexKit API key, API secret, and User Agent are not properly set in your User.xcconfig file") }
        PodcastIndexKit.setup(apiKey: apiKey, apiSecret: apiSecret, userAgent: userAgent)
    }
}

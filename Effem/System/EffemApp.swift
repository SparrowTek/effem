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
    
    var body: some Scene {
        WindowGroup {
            AppPresenter()
                .environment(state)
                .environment(podcastIndex)
                .environment(mediaPlaybackManager)
                .setupPodcastIndexKit()
                .setupModel()
                .setupDownloadManager()
                .setTheme()
        }
    }
}

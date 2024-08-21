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
    @Environment(\.scenePhase) private var scenePhase
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
                .onChange(of: scenePhase) { oldValue, newValue in
                    guard newValue != newValue else { return }
                    handleScenePhaseChange(newValue)
                }
        }
    }
    
    private func handleScenePhaseChange(_ scenePhase: ScenePhase) {
        // TODO: properly handle mediaPlaybackManager here
        switch scenePhase {
        case .active:
            break
        case .background:
            break
        case .inactive:
            break
        @unknown default:
            fatalError("A new scene phase enum case is now available and not being handled")
        }
    }
}

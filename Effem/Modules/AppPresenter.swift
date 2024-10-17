//
//  AppPresenter.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import SwiftUI
import SwiftData
import PodcastIndexKit

struct AppPresenter: View {
    @Environment(AppState.self) private var state
    
    var body: some View {
        switch state.route {
        case .main:
            MainPresenter()
                .appLoadSync()
        }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    
    AppPresenter()
        .setupPodcastIndexKit()
        .environment(AppState())
        .environment(MediaPlaybackManager())
        .environment(DownloadManager(modelContainer: context.container))
}

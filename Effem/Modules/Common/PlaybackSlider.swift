//
//  PlaybackSlider.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/1/23.
//

import SwiftUI

struct PlaybackSlider: View {
    @Environment(MediaPlaybackManager.self) private var mediaPlaybackManager
    
    var body: some View {
        @Bindable var mediaPlaybackManager = mediaPlaybackManager
        
        Slider(value: $mediaPlaybackManager.progress) { mediaPlaybackManager.didSliderChanged($0) }
            .onAppear { mediaPlaybackManager.listenToProgress() }
            .onDisappear { mediaPlaybackManager.stopListeningToProgress() }
    }
}

#Preview {
    PlaybackSlider()
        .environment(MediaPlaybackManager.shared)
}

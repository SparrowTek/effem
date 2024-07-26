//
//  PlaybackBar.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import SwiftUI

struct PlaybackBar: ViewModifier {
    @Environment(MediaPlaybackManager.self) private var mediaPlaybackManager
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    if mediaPlaybackManager.episode != nil {
                        PlaybackBarView()
                    }
                }
            }
    }
}

fileprivate struct PlaybackBarView: View {
    @Environment(AppState.self) private var state
    @Environment(MediaPlaybackManager.self) private var mediaPlaybackManager
    
    var body: some View {
        HStack {
            CommonImage(image: .url(url: mediaPlaybackManager.episode?.image, sfSymbol: nil))
                .frame(width: 50, height: 50)
                .cornerRadius(4)
            
            VStack(alignment: .leading) {
                Text(mediaPlaybackManager.episode?.title ?? "")
                    .font(.headline)
                Text(mediaPlaybackManager.episode?.datePublished?.indexFormatted() ?? "")
                    .font(.subheadline)
            }

            Spacer()
            Button(action: goBack) {
                Image(systemName: "gobackward.15")
            }
            
            Button(action: playPause) {
                Image(systemName: mediaPlaybackManager.isPlaying ? "pause.fill" : "play.fill")
            }
            
            Button(action: skipAhead) {
                Image(systemName: "goforward.30")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { showNowPlayingSheet() }
    }
    
    private func showNowPlayingSheet() {
        state.openNowPlaying()
    }
    
    private func playPause() {
        mediaPlaybackManager.playPause()
    }
    
    private func skipAhead() {
        mediaPlaybackManager.skipAhead30()
    }
    
    private func goBack() {
        mediaPlaybackManager.goBack15()
    }
}

extension View {
    func playbackBar() -> some View {
        modifier(PlaybackBar())
    }
}

#Preview {
    Color.red
    .playbackBar()
    .environment(MediaPlaybackManager())
    .environment(AppState())
}

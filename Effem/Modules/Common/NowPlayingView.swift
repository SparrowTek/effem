//
//  NowPlayingView.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/23/23.
//

import SwiftUI

struct NowPlayingView: View {
    var body: some View {
        VStack {
            EpisodeArtworkView()
            EpisodeDetailsView()
            PlaybackControlsView()
        }
        .presentationDragIndicator(.visible)
    }
}

fileprivate struct PlaybackControlsView: View {
    @Environment(MediaPlaybackManager.self) private var mediaPlaybackManager
    
    var body: some View {
        VStack {
            AudioProgressView()
            
            HStack {
                Button(action: goBack) {
                    Image(systemName: "gobackward.15")
                }
                .padding(.trailing)
                
                Button(action: playPause) {
                    Image(systemName: mediaPlaybackManager.isPlaying ? "pause.fill" : "play.fill")
                }
                .padding(.horizontal)
                
                Button(action: skipAhead) {
                    Image(systemName: "goforward.30")
                }
                .padding(.leading)
            }
            .font(.title)
        }
        .foregroundStyle(Color.darkCharcoal)
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

fileprivate struct EpisodeDetailsView: View {
    @Environment(MediaPlaybackManager.self) private var mediaPlaybackManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(mediaPlaybackManager.episode?.datePublished?.indexFormatted() ?? "")
                    .font(.subheadline)
                Text(mediaPlaybackManager.episode?.title ?? "")
                    .font(.headline)
                Text(mediaPlaybackManager.podcast?.title ?? "")
                    .setForegroundStyle()
            }
            
            Spacer()
        }
        .padding(.leading, 40)
        .padding(.top)
    }
}

fileprivate struct EpisodeArtworkView: View {
    @Environment(MediaPlaybackManager.self) private var mediaPlaybackManager
    @State private var height: CGFloat?
    
    var body: some View {
        CommonImage(image: .url(url: mediaPlaybackManager.episode?.image, sfSymbol: nil))
            .cornerRadius(20)
            .frame(maxWidth: .infinity)
            .background(GeometryReader { Color.clear.preference(key: WidthKey.self, value: $0.size.width) })
            .padding(.horizontal, 40)
            .onPreferenceChange(WidthKey.self) { height = $0 }
            .frame(height: height)
            .shadow(radius: 20)
    }
}

fileprivate struct AudioProgressView: View {
    @Environment(MediaPlaybackManager.self) private var mediaPlaybackManager
    
    var body: some View {        
        VStack {
            PlaybackSlider()
                .padding(12)
            
            HStack {
                Text(mediaPlaybackManager.currentTime)
                Spacer()
                Text(mediaPlaybackManager.timeRemaining)
            }
            .font(.system(size: 11))
        }
        .padding()
    }
}

#Preview {
    Text("test")
        .sheet(isPresented: .constant(true)) {
            NowPlayingView()
                .environment(MediaPlaybackManager())
        }
}

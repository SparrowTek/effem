//
//  MediaPlaybackManager.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import Foundation
import PodcastIndexKit
import SwiftData
import AVKit
import Combine
import MediaPlayer

@Observable
@MainActor
class MediaPlaybackManager {
    enum PlaybackType {
        case streaming
        case downlaod
    }
    
    var episode: Episode? = nil
    var podcast: Podcast? = nil
    var isPlaying = false
    
    // TODO: maybe with new features this might need to be an AVAudioEngine
    private var player: AVPlayer? = nil {
        didSet { playerDidUpdate() }
    }
    private var playbackType: PlaybackType? = .streaming
    private var timeObserver: Any?
    private var acceptProgressUpdates = true
    var currentTimePublisher = PassthroughSubject<Double, Never>()
    var currentProgressPublisher = PassthroughSubject<Double, Never>()
    private var subscriptions = Set<AnyCancellable>()
    var progress: Double = 0
    var currentTime: String = "00:00"
    var timeRemaining: String = "00:00"
    
    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers, .allowAirPlay, .allowBluetooth, .allowBluetoothA2DP])
        setupRemoteControlHandlers()
    }
    
    deinit {
        Task {
            await MainActor.run {
                pause()
                player = nil
                timeObserver = nil
                subscriptions.removeAll()
            }
        }
    }
    
    func setEpisode(_ episode: Episode?) {
        self.episode = episode
    }
    
    func setPodcast(_ podcast: Podcast?) {
        self.podcast = podcast
    }
    
    func playPause() {
        guard let episode, let enclosureUrl = episode.enclosureUrl, let url = URL(string: enclosureUrl) else { return }
        
        if isPlaying {
            stopAudio()
        } else {
            playAudio(url: url)
        }
    }
    
    func skipAhead30() {
        guard let player else { return }
        let currentTime = player.currentTime()
        let seekTime = CMTimeAdd(currentTime, CMTime(seconds: 30, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        seek(to: seekTime)
    }
    
    func goBack15() {
        guard let player else { return }
        let currentTime = player.currentTime()
        let seekTime = CMTimeSubtract(currentTime, CMTime(seconds: 15, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        seek(to: seekTime)
    }
    
    func startDownload(_ url: URL) {
        Task {
            do {
                let (localURL, _) = try await URLSession.shared.download(from: url)
                
                await MainActor.run {
                    let asset = AVURLAsset(url: localURL)
                    let item = AVPlayerItem(asset: asset)
                    print("LOCAL URL: \(localURL)")
                    print("BOOM")
                    player?.replaceCurrentItem(with: item)
                    play()
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func playAudio(url: URL) {
        switch playbackType {
        case .streaming:
            playStreamingAudio(url)
            //            startDownload(url)
        case .downlaod:
            return
        case .none:
            return
        }
    }
    
    private func playStreamingAudio(_ url: URL) {
        if player == nil {
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
        }
        
        setupPeriodicObservation(for: player)
        
        play()
    }
    
    private func timeDidUpdate(_ time: CMTime) {
        let currentTime = CMTimeGetSeconds(time)
        self.currentTime = secondsToTimeString(currentTime)
        
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            timeRemaining = secondsToTimeString(totalSeconds - currentTime)
            progress = currentTime / totalSeconds
        }
    }
    
    private func secondsToTimeString(_ seconds: Float64) -> String {
        guard seconds.isFinite && !seconds.isNaN else { return "00:00" }
        
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let seconds = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func stopAudio() {
        switch playbackType {
        case .streaming:
            pause()
        case .downlaod:
            break
        case .none:
            break
        }
    }
    
    private func killCurrentEpisode() {
        stopAudio()
        
        switch playbackType {
        case .streaming:
            player = nil
            if let timeObserver {
                player?.removeTimeObserver(timeObserver)
            }
        case .downlaod:
            break
        case .none:
            break
        }
        
        episode = nil
    }
    
    private func playerDidUpdate() {
        if let player {
            setupPeriodicObservation(for: player)
        } else {
            timeObserver = nil
        }
    }
    
    private func setupPeriodicObservation(for player: AVPlayer?) {
        guard let player, timeObserver == nil else { return }
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] (time) in
            Task { [weak self] in
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    let progress = self.calculateProgress(currentTime: time.seconds)
                    self.currentProgressPublisher.send(progress)
                    self.currentTimePublisher.send(time.seconds)
                    self.timeDidUpdate(time)
                }
            }
        }
    }
    
    private func calculateProgress(currentTime: Double) -> Double {
        return currentTime / duration
    }
    
    private var duration: Double {
        return player?.currentItem?.duration.seconds ?? 0
    }
    
    func play() {
        updateNowPlayingInfo()
        player?.play()
        isPlaying = true
        try? AVAudioSession.sharedInstance().setActive(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    func pause() {
        updateNowPlayingInfo()
        player?.pause()
        isPlaying = false
        try? AVAudioSession.sharedInstance().setActive(false)
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    func seek(to time: CMTime) {
        player?.seek(to: time)
    }
    
    func seek(to percentage: Double) {
        let time = convertFloatToCMTime(percentage)
        player?.seek(to: time)
    }
    
    private func convertFloatToCMTime(_ percentage: Double) -> CMTime {
        return CMTime(seconds: duration * Double(percentage), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    }
    
    
    // MARK: player slider logic
    
    func listenToProgress() {
        currentProgressPublisher.sink { [weak self] progress in
            guard let self, acceptProgressUpdates else { return }
            self.progress = progress
        }.store(in: &subscriptions)
    }
    
    func stopListeningToProgress() {
        subscriptions.removeAll()
    }
    
    func userIsMovingSlider() {
        acceptProgressUpdates = false
        
        let time = convertFloatToCMTime(progress)
        timeDidUpdate(time)
    }
    
    func userStoppedMovingSlider() {
        seek(to: progress)
        
        // TODO: is this the best way to solve the issue?
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            acceptProgressUpdates = true
        }
    }
}

// MARK: Media Center
extension MediaPlaybackManager {
    func setupRemoteControlHandlers() {
        let center = MPRemoteCommandCenter.shared()
        
        center.playCommand.addTarget { [weak self] _ in
            guard let self, let player else { return .noActionableNowPlayingItem }
            player.play()
            return .success
        }
        
        center.pauseCommand.addTarget { [weak self] _ in
            guard let self, let player else { return .noActionableNowPlayingItem }
            player.pause()
            return .success
        }
        
        center.stopCommand.addTarget { [weak self] _ in
            guard let self, let player else { return .noActionableNowPlayingItem }
            player.pause()
            return .success
        }
        
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .noActionableNowPlayingItem }
            isPlaying ? pause() : play()
            return .success
        }
        
        center.skipForwardCommand.addTarget { _ in
                .success
        }
        
        center.skipBackwardCommand.addTarget { _ in
                .success
        }
    }
    
    private func updateNowPlayingInfo() {
        
        if let episode {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: episode.title ?? "",
                MPMediaItemPropertyArtist: podcast?.author ?? "",
                MPMediaItemPropertyPlaybackDuration: episode.duration ?? 0,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
//                MPMediaItemPropertyArtwork: artwork
//                MPNowPlayingInfoPropertyPlaybackRate: playbackSpeed.rate
            ]
            
            
            
//            if let image = UIImage(named: "song1") {
//                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
//                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
//            }
        } else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        }
    }
}

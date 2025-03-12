//
//  SetupPodcastIndexKit.swift
//  Effem
//
//  Created by Thomas Rademaker on 7/12/24.
//

import SwiftUI
import PodcastIndexKit

#warning("all of this can be deleted once Effem servers are up and running")

fileprivate struct SetupPodcastIndexKit: ViewModifier {
    func body(content: Content) -> some View {
        content
            .task { await setupPodcastIndexKit() }
    }
    
    private func setupPodcastIndexKit() async {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let apiKey = infoDictionary["PodcastIndexAPIKey"] as? String,
              let apiSecret = infoDictionary["PodcastIndexAPISecret"] as? String,
              let userAgent = infoDictionary["PodcastIndexUserAgent"] as? String else { fatalError("PodcastIndexKit API key, API secret, and User Agent are not properly set in your User.xcconfig file") }
        await PodcastIndexKit.setup(apiKey: apiKey, apiSecret: apiSecret, userAgent: userAgent)
    }
}

extension View {
    func setupPodcastIndexKit() -> some View {
        modifier(SetupPodcastIndexKit())
    }
}

#Preview {
    Text("Setup Podcast Index Kit")
        .setupPodcastIndexKit()
}

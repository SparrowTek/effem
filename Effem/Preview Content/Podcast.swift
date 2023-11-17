//
//  Podcast.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/14/23.
//

import Foundation
import PodcastIndexKit

extension Podcast {
    static var preview: Podcast {
        let podcastFile = Bundle.main.url(forResource: "podcastresponse", withExtension: "json")!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let data = try! Data(contentsOf: podcastFile)
        let podcastResponse = try! decoder.decode(PodcastResponse.self, from: data)
        return podcastResponse.feed!
    }
}

//
//  Episode.swift
//  Effem
//
//  Created by Thomas Rademaker on 9/25/24.
//

import Foundation
import PodcastIndexKit

extension Episode {
    static var preview: Episode {
        let episodeFile = Bundle.main.url(forResource: "episodeArrayResponse", withExtension: "json")!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let data = try! Data(contentsOf: episodeFile)
        let episodes = try! decoder.decode(EpisodeArrayResponse.self, from: data)
        return episodes.items!.first!
    }
}

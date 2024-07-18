//
//  FMEpisode.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/1/23.
//

import Foundation
import SwiftData
import PodcastIndexKit

//public enum FMEpisodeSchemaV1: VersionedSchema {
//    public static var versionIdentifier = Schema.Version(1, 0, 0)
//    
//    public static var models: [any PersistentModel.Type] {
//        [FMEpisode.self]
//    }
    
@Model
class FMEpisode {
    let episode: Episode
    let podcast: Podcast?
    var playPosition: Double
    @Attribute(.externalStorage) var audioFile: Data?
    
    init(episode: Episode, playPosition: Double = 0) {
        self.episode = episode
        self.playPosition = playPosition
    }
}
//}

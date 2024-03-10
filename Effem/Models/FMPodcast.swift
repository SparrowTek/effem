//
//  FMPodcast.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/1/23.
//

import Foundation
import SwiftData
import PodcastIndexKit

//public enum FMPodcastSchemaV1: VersionedSchema {
//    public static var versionIdentifier = Schema.Version(1, 0, 0)
//    
//    public static var models: [any PersistentModel.Type] {
//        [FMPodcast.self]
//    }
    
@Model
class FMPodcast {
    let id: Int?
    let title: String?
    let url: String?
    let originalUrl: String?
    let link: String?
    let podcastDescription: String?
    let author: String?
    let ownerName: String?
    let image: String?
    let artwork: String?
    let lastUpdateTime: Date?
    let lastCrawlTime: Date?
    let lastParseTime: Date?
    let lastGoodHttpStatusTime: Date?
    let lastHttpStatus: Int?
    let contentType: String?
    let itunesId: Int?
    let generator: String?
    let language: String?
    let type: PodcastType?
    let dead: Int?
    let crawlErrors: Int?
    let parseErrors: Int?
    let categories: [String : String]?
    let locked: PodcastLocked?
    let podcastGuid: String?
    let episodeCount: Int?
    let imageUrlHash: Double?
    let newestItemPubdate: Date?
    let explicit: Bool?
    let itunesType: String?
    let chash: String?
    let value: PodcastValue?
    let funding: PodcastFunding?
    
    convenience init(podcast: Podcast) {
        self.init(id: podcast.id, title: podcast.title, url: podcast.url, originalUrl: podcast.originalUrl, link: podcast.link, podcastDescription: podcast.podcastDescription, author: podcast.author, ownerName: podcast.ownerName, image: podcast.image, artwork: podcast.artwork, lastUpdateTime: podcast.lastUpdateTime, lastCrawlTime: podcast.lastCrawlTime, lastParseTime: podcast.lastParseTime, lastGoodHttpStatusTime: podcast.lastGoodHttpStatusTime, lastHttpStatus: podcast.lastHttpStatus, contentType: podcast.contentType, itunesId: podcast.itunesId, generator: podcast.generator, language: podcast.language, type: podcast.type, dead: podcast.dead, crawlErrors: podcast.crawlErrors, parseErrors: podcast.parseErrors, categories: podcast.categories, locked: podcast.locked, podcastGuid: podcast.podcastGuid, episodeCount: podcast.episodeCount, imageUrlHash: podcast.imageUrlHash, newestItemPubdate: podcast.newestItemPubdate, explicit: podcast.explicit, itunesType: podcast.itunesType, chash: podcast.chash, value: podcast.value, funding: podcast.funding)
    }
    
    init(id: Int?, title: String?, url: String?, originalUrl: String?, link: String?, podcastDescription: String?, author: String?, ownerName: String?, image: String?, artwork: String?, lastUpdateTime: Date?, lastCrawlTime: Date?, lastParseTime: Date?, lastGoodHttpStatusTime: Date?, lastHttpStatus: Int?, contentType: String?, itunesId: Int?, generator: String?, language: String?, type: PodcastType?, dead: Int?, crawlErrors: Int?, parseErrors: Int?, categories: [String : String]?, locked: PodcastLocked?, podcastGuid: String?, episodeCount: Int?, imageUrlHash: Double?, newestItemPubdate: Date?, explicit: Bool?, itunesType: String?, chash: String?, value: PodcastValue?, funding: PodcastFunding?) {
        self.id = id
        self.title = title
        self.url = url
        self.originalUrl = originalUrl
        self.link = link
        self.podcastDescription = podcastDescription
        self.author = author
        self.ownerName = ownerName
        self.image = image
        self.artwork = artwork
        self.lastUpdateTime = lastUpdateTime
        self.lastCrawlTime = lastCrawlTime
        self.lastParseTime = lastParseTime
        self.lastGoodHttpStatusTime = lastGoodHttpStatusTime
        self.lastHttpStatus = lastHttpStatus
        self.contentType = contentType
        self.itunesId = itunesId
        self.generator = generator
        self.language = language
        self.type = type
        self.dead = dead
        self.crawlErrors = crawlErrors
        self.parseErrors = parseErrors
        self.categories = categories
        self.locked = locked
        self.podcastGuid = podcastGuid
        self.episodeCount = episodeCount
        self.imageUrlHash = imageUrlHash
        self.newestItemPubdate = newestItemPubdate
        self.explicit = explicit
        self.itunesType = itunesType
        self.chash = chash
        self.value = value
        self.funding = funding
    }
}
//}

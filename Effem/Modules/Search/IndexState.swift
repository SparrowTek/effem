//
//  IndexState.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import Foundation
import SwiftData
import PodcastIndexKit

@Observable
class IndexState {
    enum Sheet: Int, Identifiable {
        case podcastIndexInfo
        
        var id: Int { rawValue }
    }
    
    private unowned let parentState: AppState
    var path: [Podcast] = []
    var podcasts: [Podcast] = []
    var sheet: Sheet?
    
    init(parentState: AppState) {
        self.parentState = parentState
    }
}

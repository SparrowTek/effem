//
//  SearchState.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import Foundation
import SwiftUI
import SwiftData
import PodcastIndexKit

@Observable
@MainActor
class SearchState {
    enum Sheet: Int, Identifiable {
        case podcastIndexInfo
        
        var id: Int { rawValue }
    }
    
    enum Path: Hashable {
        case podcast(Podcast)
        case category(FMCategory)
    }
    
    private unowned let parentState: AppState
    var path: [SearchState.Path] = []
    var sheet: Sheet?
    
    init(parentState: AppState) {
        self.parentState = parentState
    }
}

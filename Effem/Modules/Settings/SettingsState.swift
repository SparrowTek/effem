//
//  SettingsState.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/24/23.
//

import Foundation
import SwiftData

@Observable
class SettingsState {
    enum NavigationLink: Hashable {
        case about
        case privacy
        case podcasterInfo
        case podcastIndexInfo
        case storage
    }
    
    private unowned let parentState: AppState
    var path: [SettingsState.NavigationLink] = []
    
    init(parentState: AppState) {
        self.parentState = parentState
    }
}

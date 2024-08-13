//
//  AppState.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import Foundation
import SwiftData

@Observable
@MainActor
public class AppState {
    enum Route {
        case main
    }
    
    enum Sheet: Int, Identifiable {
        case nowPlaying
        case settings
        case downloads
        case search
        
        var id: Int {
            self.rawValue
        }
    }

    var route: Route = .main
    var sheet: Sheet? = nil
    
    public init() {}
    
    @ObservationIgnored
    lazy var searchState = SearchState(parentState: self)
    @ObservationIgnored
    lazy var settingsState = SettingsState(parentState: self)
    
    func openSettings() {
        sheet = .settings
    }
    
    func openDownloads() {
        sheet = .downloads
    }
    
    func openSearch() {
        sheet = .search
    }
    
    func openNowPlaying() {
        sheet = .nowPlaying
    }
}

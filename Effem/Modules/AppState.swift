//
//  AppState.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import Foundation
import SwiftData

@Observable
public class AppState {
    enum Route {
        case main
    }
    
    enum Tab {
        case library
        case index
        case social
    }
    
    enum Sheet: Int, Identifiable {
        case nowPlaying
        case settings
        case downloads
        
        var id: Int {
            self.rawValue
        }
    }

    var route: Route = .main
    var tab: Tab = .library
    var sheet: Sheet? = nil
    
    var downloadInProgress = true
    
    public init() {}
    
    @ObservationIgnored
    lazy var indexState = IndexState(parentState: self)
    @ObservationIgnored
    lazy var libraryState = LibraryState(parentState: self)
    @ObservationIgnored
    lazy var socialState = SocialState(parentState: self)
    @ObservationIgnored
    lazy var settingsState = SettingsState(parentState: self)
    
    func openSettings() {
        sheet = .settings
    }
    
    func openDownloads() {
        sheet = .downloads
    }
    
    func addItem() {
        
    }
    
    func openNowPlaying() {
        sheet = .nowPlaying
    }
}

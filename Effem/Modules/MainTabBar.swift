//
//  MainTabBar.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import SwiftUI

/*
struct MainTabBar: View {
    @Environment(AppState.self) private var state
    @Environment(MediaPlaybackManager.self) private var mediaPlaybackManager
    @State private var triggerSensoryFeedback = false
    
    var body: some View {
        @Bindable var state = state
        
        TabView(selection: $state.tab) {
            Group {
                LibraryPresenter()
                    .environment(state.libraryState)
                    .tag(AppState.Tab.library)
                    .tabItem { Label("library", systemImage: "square.stack.fill")}
                
                IndexPresenter()
                    .environment(state.indexState)
                    .tag(AppState.Tab.index)
                    .tabItem { Label("index", systemImage: "magnifyingglass")}
                
                SocialPresenter()
                    .environment(state.socialState)
                    .tag(AppState.Tab.social)
                    .tabItem { Label("social", systemImage: "party.popper")}
            }
            .playbackBar()
//            .toolbarBackground(.visible, for: .tabBar)
//            .toolbarBackground(Color.primaryWhite, for: .tabBar)
        }
        .onChange(of: state.tab) { triggerSensoryFeedback.toggle() }
        .sensoryFeedback(.selection, trigger: triggerSensoryFeedback)
        .setTheme()
        .sheet(item: $state.sheet) {
            switch $0 {
            case .nowPlaying:
                NowPlayingView()
                    .setTheme()
            case .settings:
                SettingsPresenter()
                    .environment(state.settingsState)
                    .setTheme()
            case .downloads:
                Text("DOWNLOADS")
                    .presentationDragIndicator(.visible)
            }
        }
        
    }
}

#Preview {
    MainTabBar()
        .environment(AppState())
        .environment(MediaPlaybackManager.shared)
}
*/

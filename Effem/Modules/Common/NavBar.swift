//
//  NavBar.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import SwiftUI

#warning("this modifier should probably be deprecated")
fileprivate struct NavBar: ViewModifier {
    @Environment(AppState.self) private var state
    @Environment(DownloadManager.self) private var downloadManager
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                content
                    .toolbarBackground(.hidden, for: .navigationBar)
                
                VStack {
                    Color.primaryBackground
                        .frame(height: geometry.safeAreaInsets.top)
                        .ignoresSafeArea()
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: openSettings) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        if downloadManager.hasDownloadsInProgress {
                            Button(action: openDownloads) {
                                Image(systemName: "icloud.and.arrow.down")
                            }
                        }
                        
                        Button(action: openSearch) {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
            }
        }
    }
    
    private func openSettings() {
        state.openSettings()
    }
    
    private func openDownloads() {
        state.openDownloads()
    }
    
    private func openSearch() {
        state.openSearch()
    }
}

extension View {
    /// A view modifier to display the Effem nav bar
    func navBar() -> some View {
        modifier(NavBar())
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    
    NavigationStack {
        Text("Test")
            .commonView()
            .navBar()
    }
    .environment(AppState())
    .environment(MediaPlaybackManager())
    .environment(DownloadManager(modelContainer: context.container))
}

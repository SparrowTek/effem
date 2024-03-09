//
//  SettingsPresenter.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/24/23.
//

import SwiftUI

@MainActor
struct SettingsPresenter: View {
    @Environment(SettingsState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        NavigationStack(path: $state.path) {
            SettingsView()
                .navigationDestination(for: SettingsState.NavigationLink.self) {
                    switch $0 {
                    case .privacy:
                        Text("Privacy policy")
                            .interactiveDismissDisabled()
                    case .about:
                        Text("About")
                            .interactiveDismissDisabled()
                    case .podcasterInfo:
                        Text("Podcaster Info")
                            .interactiveDismissDisabled()
                    case .podcastIndexInfo:
                        Text("Podcast Index Info")
                            .interactiveDismissDisabled()
                    case .storage:
                        Text("Storage")
                            .interactiveDismissDisabled()
                    case .theme:
                        ThemeSettingsView()
                            .interactiveDismissDisabled()
                    }
                }
        }
        
    }
}

@MainActor
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var icloudSync = false
    @State private var allowDownloading = false
    @State private var allowStreaming = false
    
    var body: some View {
        Form {
            Section {
                NavigationLink(value: SettingsState.NavigationLink.storage) {
                    Label("storage", systemImage: "externaldrive.fill")
                }
                
                NavigationLink(value: SettingsState.NavigationLink.theme) {
                    Label("theme", systemImage: "line.3.crossed.swirl.circle.fill")
                }
            }
            
            Section("cellular network") {
                Toggle("allow downloading", isOn: $allowDownloading)
                Toggle("allow streaming", isOn: $allowStreaming)
            }
            
            Section("iCloud sync") {
                Toggle("enable sync", isOn: $icloudSync)
            }
            
            Section {
                
                NavigationLink(value: SettingsState.NavigationLink.podcastIndexInfo) {
                    Label("podcasting 2.0", systemImage: "waveform")
                }
                
                NavigationLink(value: SettingsState.NavigationLink.podcasterInfo) {
                    Label("info for podcasters", systemImage: "mic.fill")
                }
                
                NavigationLink(value: SettingsState.NavigationLink.privacy) {
                    Label("privacy", systemImage: "hand.raised.fill")
                }
                
                NavigationLink(value: SettingsState.NavigationLink.about) {
                    Label("about", systemImage: "info")
                }
            }
        }
        .commonView()
        .navigationTitle("settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: { dismiss() })
            }
        }
    }
}

#Preview {
    Text("EFFEM")
        .sheet(isPresented: .constant(true)) {
            SettingsPresenter()
                .environment(SettingsState(parentState: .init()))
        }
}

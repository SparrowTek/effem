//
//  SettingsPresenter.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/24/23.
//

import SwiftUI

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
                    }
                }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var icloudSync = false
    @State private var allowDownloading = false
    
    // MARK: color scheme properties
    @State private var selectedColorScheme = 0
    @AppStorage(Build.Constants.UserDefault.colorScheme) private var colorSchemeString: String?
    
    var body: some View {
        Form {
            Section {
                NavigationLink(value: SettingsState.NavigationLink.storage) {
                    Label("storage", systemImage: "externaldrive.fill")
                }
            }
            
            Section("cellular network") {
                Toggle("allow downloading", isOn: $allowDownloading)
            }
            
            Section("iCloud sync") {
                Toggle("enable sync", isOn: $icloudSync)
            }
            
            Section("color scheme") {
                Picker("selected color scheme", selection: $selectedColorScheme) {
                    Text("system").tag(0)
                    Text("light").tag(1)
                    Text("dark").tag(2)
                }
                .pickerStyle(.segmented)
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
        .fullScreenColorView()
        .navigationTitle("settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("done", action: { dismiss() })
            }
        }
        .onAppear(perform: setSelectedColorScheme)
        .onChange(of: selectedColorScheme, updateColorScheme)
    }
    
    // MARK: Color scheme methods
    private func setSelectedColorScheme() {
        switch colorSchemeString {
        case Build.Constants.Theme.light: selectedColorScheme = 1
        case Build.Constants.Theme.dark: selectedColorScheme = 2
        default: selectedColorScheme = 0
        }
    }
    
    private func updateColorScheme() {
        switch selectedColorScheme {
        case 1: colorSchemeString = Build.Constants.Theme.light
        case 2: colorSchemeString = Build.Constants.Theme.dark
        default: colorSchemeString = nil
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

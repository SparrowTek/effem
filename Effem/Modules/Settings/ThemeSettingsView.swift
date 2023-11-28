//
//  ThemeSettingsView.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/24/23.
//

import SwiftUI

struct ThemeSettingsView: View {
    @AppStorage(Build.Constants.UserDefault.lightThemeColor) private var lightThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.darkThemeColor) private var darkThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.colorScheme) private var colorSchemeString: String?
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedColorScheme = 0
    
    var body: some View {
        Form {
            Section("color scheme") {
                Picker("Selected Color Scheme", selection: $selectedColorScheme) {
                    Text("system").tag(0)
                    Text("light").tag(1)
                    Text("dark").tag(2)
                }
                .pickerStyle(.segmented)
            }
        }
        .onChange(of: selectedColorScheme, updateColorScheme)
        .onAppear(perform: setSelectedColorScheme)
    }
    
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
    ThemeSettingsView()
}

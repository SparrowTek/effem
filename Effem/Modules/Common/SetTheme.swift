//
//  SetTheme.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/24/23.
//

import SwiftUI

fileprivate struct SetThemeViewModifier: ViewModifier {
    @AppStorage(Build.Constants.UserDefault.lightThemeColor) private var lightThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.darkThemeColor) private var darkThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.colorScheme) private var colorSchemeString: String?
    @Environment(\.colorScheme) private var colorScheme
    
    private var setColorScheme: ColorScheme? {
        switch colorSchemeString {
        case Build.Constants.Theme.light: .light
        case Build.Constants.Theme.dark: .dark
        default: nil
        }
    }
    
    private var lightColor: Color {
        guard let lightThemeColor,
              let colorData = lightThemeColor.data(using: .utf8),
              let colorResolved = try? JSONDecoder().decode(Color.Resolved.self, from: colorData) else { return .accentColor }
        return Color(colorResolved)
    }
    
    private var darkColor: Color {
        guard let darkThemeColor,
              let colorData = darkThemeColor.data(using: .utf8),
              let colorResolved = try? JSONDecoder().decode(Color.Resolved.self, from: colorData) else { return .accentColor }
        return Color(colorResolved)
    }
    
    func body(content: Content) -> some View {
        content
            .tint(colorScheme == .light ? lightColor : darkColor)
            .preferredColorScheme(setColorScheme)
    }
}

extension View {
    func setTheme() -> some View {
        modifier(SetThemeViewModifier())
    }
}

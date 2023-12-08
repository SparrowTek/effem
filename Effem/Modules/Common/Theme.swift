//
//  SetTheme.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/24/23.
//

import SwiftUI

fileprivate struct SetForegroundStyleViewModifier: ViewModifier {
    @AppStorage(Build.Constants.UserDefault.lightThemeColor) private var lightThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.darkThemeColor) private var darkThemeColor: String?
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(colorScheme == .light ? lightThemeColor.color : darkThemeColor.color)
    }
}

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
    
    func body(content: Content) -> some View {
        content
            .tint(colorScheme == .light ? lightThemeColor.color : darkThemeColor.color)
            .preferredColorScheme(setColorScheme)
    }
}

extension View {
    func setTheme() -> some View {
        modifier(SetThemeViewModifier())
    }
    
    func setForegroundStyle() -> some View {
        modifier(SetForegroundStyleViewModifier())
    }
}

//
//  SetTheme.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/24/23.
//

import SwiftUI

fileprivate struct SetThemeViewModifier: ViewModifier {
    @AppStorage(Build.Constants.UserDefault.lightThemeColor) private var lightThemeColor: String = "[0.12941176,0.12941176,0.12941176,1]"
    @AppStorage(Build.Constants.UserDefault.darkThemeColor) private var darkThemeColor: String = "[0.9647059,0.97647065,0.97647065,1]"
    @AppStorage(Build.Constants.UserDefault.colorScheme) private var colorSchemeString: String?
    @Environment(\.colorScheme) private var colorScheme
    
    private var setColorScheme: ColorScheme? {
        switch colorSchemeString {
        case "light": .light
        case "dark": .dark
        default: nil
        }
    }
    
    private var lightColor: Color {
        guard let colorData = lightThemeColor.data(using: .utf8),
              let colorResolved = try? JSONDecoder().decode(Color.Resolved.self, from: colorData) else { return .accentColor }
        return Color(colorResolved)
    }
    
    private var darkColor: Color {
        guard let colorData = darkThemeColor.data(using: .utf8),
              let colorResolved = try? JSONDecoder().decode(Color.Resolved.self, from: colorData) else { return .accentColor }
        return Color(colorResolved)
    }
    
    func body(content: Content) -> some View {
        content
            .tint(colorScheme == .light ? lightColor : darkColor)
            .preferredColorScheme(colorScheme)
    }
}

extension View {
    func setTheme() -> some View {
        modifier(SetThemeViewModifier())
    }
}

//
//  ThemedCircle.swift
//  Effem
//
//  Created by Thomas Rademaker on 12/8/23.
//

import SwiftUI

struct ThemedCircle: View {
    @AppStorage(Build.Constants.UserDefault.lightThemeColor) private var lightThemeColor: String?
    @AppStorage(Build.Constants.UserDefault.darkThemeColor) private var darkThemeColor: String?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Circle()
            .fill(colorScheme == .light ? lightThemeColor.color : darkThemeColor.color)
    }
}

#Preview {
    ThemedCircle()
}

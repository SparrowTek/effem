//
//  SocialView.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/19/23.
//

import SwiftUI

struct SocialPresenter: View {
    @Environment(SocialState.self) private var state
    
    var body: some View {
        NavigationStack {
            SocialView()
        }
    }
}

struct SocialView: View {
    var body: some View {
        Text("SOCIAL")
            .navBar()
            .commonView()
    }
}

#Preview {
    NavigationStack {
        SocialView()
            .environment(SocialState(parentState: .init()))
            .environment(MediaPlaybackManager.shared)
            .environment(AppState())
    }
}

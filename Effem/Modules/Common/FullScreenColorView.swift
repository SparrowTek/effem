//
//  FullScreenColorView.swift
//  Effem
//
//  Created by Thomas Rademaker on 10/12/23.
//

import SwiftUI

fileprivate struct FullScreenColorView: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        ZStack {
            color.ignoresSafeArea()
            content
        }
    }
}

extension View {
    func fullScreenColorView(_ color: Color = .primaryBackground) -> some View {
        modifier(FullScreenColorView(color: color))
    }
}

#Preview {
    Text("Common view")
        .fullScreenColorView()
        .foregroundStyle(.black)
}

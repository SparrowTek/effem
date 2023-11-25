//
//  CommonView.swift
//  Effem
//
//  Created by Thomas Rademaker on 10/12/23.
//

import SwiftUI

fileprivate struct CommonView: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.primaryBackground
            content
        }
    }
}

extension View {
    func commonView() -> some View {
        modifier(CommonView())
    }
}

#Preview {
    Text("Common view")
        .commonView()
        .foregroundStyle(.black)
}


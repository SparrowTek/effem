//
//  WidthKey.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/23/23.
//

import SwiftUI

struct WidthKey: PreferenceKey {
    static let defaultValue: CGFloat? = nil
    
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

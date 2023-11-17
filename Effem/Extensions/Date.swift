//
//  Date.swift
//  Effem
//
//  Created by Thomas Rademaker on 5/23/23.
//

import Foundation

extension Date {
    func indexFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
}

//
//  FMCategory.swift
//  Effem
//
//  Created by Thomas Rademaker on 7/20/24.
//

import SwiftData

@Model
class FMCategory {
    @Attribute(.unique) var id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

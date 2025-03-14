//
//  Services.swift
//  Effem
//
//  Created by Thomas Rademaker on 3/12/25.
//

import SwiftData
import SwiftUI

@Observable
class Services {
    let run: ServicesModelActor
    
    init(run: ServicesModelActor) {
        self.run = run
    }
}


@ModelActor
actor ServicesModelActor {
    
}


struct ServicesViewModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    func body(content: Content) -> some View {
        content
//            .environment(\.services, Services(run: ServicesModelActor(modelContainer: modelContext.container)))
            .environment(Services(run: ServicesModelActor(modelContainer: modelContext.container)))
    }
}

extension View {
    func setupServices() -> some View {
        modifier(ServicesViewModifier())
    }
}

//@MainActor
//struct ServicesKey: @preconcurrency EnvironmentKey {
//    static let defaultValue: Services = {
//        fatalError("Services not provided in environment. Use .setupServices() on your root view.")
//    }()
//}
//
//extension EnvironmentValues {
//    var services: Services {
//        get { self[ServicesKey.self] }
//        set { self[ServicesKey.self] = newValue }
//    }
//}

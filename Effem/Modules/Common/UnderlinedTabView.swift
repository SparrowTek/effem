//
//  UnderlinedTabView.swift
//  Effem
//
//  Created by Thomas Rademaker on 12/7/23.
//

import SwiftUI

@Observable
class UnderlinedTabState {
    let tabs: [UnderlinedTab]
    var selectedTabIndex: Int
    var tabIndex: Int
    
    init(tabs: [UnderlinedTab], selectedTabIndex: Int = 0, tabIndex: Int = 0) {
        self.tabs = tabs
        self.selectedTabIndex = selectedTabIndex
        self.tabIndex = tabIndex
    }
}

struct UnderlinedTabView<Content, Style>: View where Content: View, Style: TabViewStyle {
    @Environment(UnderlinedTabState.self) private var state
    let tabViewStyle: Style
    let content: Content
    
    init(tabViewStyle: Style, @ViewBuilder content: () -> Content) {
        self.tabViewStyle = tabViewStyle
        self.content = content()
    }
    
    var body: some View {
        @Bindable var state = state
        
        VStack {
            UnderlinedTabHStack()
            
            TabView(selection: $state.tabIndex) {
                content
            }
            .tabViewStyle(tabViewStyle)
            .onChange(of: state.tabIndex) { withAnimation { state.selectedTabIndex = state.tabIndex } }
            .onChange(of: state.selectedTabIndex) { withAnimation { state.tabIndex = state.selectedTabIndex } }
        }
    }
}

struct UnderlinedTabHStack: View {
    @Environment(UnderlinedTabState.self) private var state
    
    var body: some View {
        @Bindable var state = state
        
        HStack(spacing: 20) {
            ForEach(state.tabs) { tab in
                UnderlinedTabButton(tab: tab, selection: $state.selectedTabIndex)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .overlayPreferenceValue(UnderlinedTabPreferenceKey.self) { preferences in
            GeometryReader { proxy in
                if let selected = preferences.first(where: { $0.tab.id == state.selectedTabIndex }) {
                    let frame = proxy[selected.anchor]
                    
                    ThemedRectangle()
                        .frame(width: frame.width, height: 2)
                        .position(x: frame.midX, y: frame.maxY)
                }
            }
        }
    }
}

struct UnderlinedTabButton: View {
    var tab: UnderlinedTab
    @Binding var selection: Int
    
    var body: some View {
        Button(action: selectionMade) {
            Text(tab.title)
                .setForegroundStyle()
        }
        .buttonStyle(.plain)
        .accessibilityElement()
        .accessibilityLabel(Text(tab.title))
        .anchorPreference(key: UnderlinedTabPreferenceKey.self, value: .bounds, transform: { [UnderlinedTabPreference(tab: tab, anchor: $0)] })
    }
    
    private func selectionMade() {
        withAnimation { selection = tab.id }
    }
}

struct UnderlinedTab: Identifiable, Equatable, Hashable {
    let id: Int
    let title: LocalizedStringResource
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine("\(title)")
    }
}

struct UnderlinedTabPreference: Equatable {
    let tab: UnderlinedTab
    let anchor: Anchor<CGRect>
}

struct UnderlinedTabPreferenceKey: PreferenceKey {
    static let defaultValue = [UnderlinedTabPreference]()
    
    static func reduce(value: inout [UnderlinedTabPreference], nextValue: () -> [UnderlinedTabPreference]) {
        value.append(contentsOf: nextValue())
    }
}

#Preview {
    UnderlinedTabView(tabViewStyle: .page(indexDisplayMode: .never)) {
        Text("episodes")
            .foregroundStyle(.black)
            .tag(0)
            .commonView()
        Text("shows")
            .foregroundStyle(.black)
            .tag(1)
            .commonView()
    }
    .environment(UnderlinedTabState(tabs: [
        .init(id: 0, title: "Episodes"),
        .init(id: 1, title: "Shows"),
    ]))
    .commonView()
}

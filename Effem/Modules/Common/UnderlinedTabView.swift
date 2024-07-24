//
//  UnderlinedTabView.swift
//  Effem
//
//  Created by Thomas Rademaker on 12/7/23.
//

import SwiftUI

struct UnderlinedTabView<Content, Style>: View where Content: View, Style: TabViewStyle {
    let tabs: [UnderlinedTab]
    let tabViewStyle: Style
    let content: Content
    
    @State private var selectedTabIndex: Int = 0
    @State private var tabIndex: Int = 0
    
    init(tabs: [UnderlinedTab], tabViewStyle: Style, @ViewBuilder content: () -> Content) {
        self.tabs = tabs
        self.tabViewStyle = tabViewStyle
        self.content = content()
    }
    
    var body: some View {
        VStack {
            UnderlinedTabHStack(selectedTabIndex: $selectedTabIndex, tabs: tabs)
            
            TabView(selection: $tabIndex) {
                content
            }
            .tabViewStyle(tabViewStyle)
            .onChange(of: tabIndex) { withAnimation { selectedTabIndex = tabIndex } }
            .onChange(of: selectedTabIndex) { withAnimation { tabIndex = selectedTabIndex } }
        }
    }
}

struct UnderlinedTabHStack: View {
    @Binding var selectedTabIndex: Int
    let tabs: [UnderlinedTab]
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(tabs) { tab in
                UnderlinedTabButton(tab: tab, selection: $selectedTabIndex)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .overlayPreferenceValue(UnderlinedTabPreferenceKey.self) { preferences in
            GeometryReader { proxy in
                if let selected = preferences.first(where: { $0.tab.id == selectedTabIndex }) {
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
    let tabs: [UnderlinedTab] = [
        .init(id: 0, title: "Episodes"),
        .init(id: 1, title: "Shows"),
    ]
    
    return UnderlinedTabView(tabs: tabs, tabViewStyle: .page(indexDisplayMode: .never)) {
        Text("episodes")
            .foregroundStyle(.black)
            .tag(0)
            .commonView()
        Text("shows")
            .foregroundStyle(.black)
            .tag(1)
            .commonView()
    }
    .commonView()
}

//
//  AppState.swift
//  Template
//
//  Created by Brett Meader on 02/04/2024.
//

import SwiftUI
import SwiftData

private struct ThemeStateContainerModifier: ViewModifier {
    @State private var theme: AppTheme = .default
    func body(content: Content) -> some View {
        content
            .environment(\.appTheme, $theme)
    }
}

private struct RouterStateContainerModifier: ViewModifier {
    @State private var router: AppRouter = .init()
    func body(content: Content) -> some View {
        content
            .environment(router)
    }
}

private extension View {
    func routerStateContainer() -> some View {
        modifier(RouterStateContainerModifier())
    }
}

private extension View {
    func themeStateContainer() -> some View {
        modifier(ThemeStateContainerModifier())
    }
}

struct AppStateContainer<Content: View>: View {
    @Environment(\.modelContext) var modelContext
    var content: () -> Content
    var body: some View {
        content()
            .enableFeature(Feature.deepLinks)
            .routerStateContainer()
            .themeStateContainer()
            
    }
}

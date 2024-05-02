//
//  AppState.swift
//  Template
//
//  Created by Brett Meader on 02/04/2024.
//

import SwiftUI
import SwiftData

struct ThemeStateContainerModifier: ViewModifier {
    @State private var theme: AppTheme = .default
    func body(content: Content) -> some View {
        content
            .environment(\.appTheme, $theme)
    }
}

struct RouterStateContainerModifier: ViewModifier {
    @State private var router: AppRouter = .init()
    func body(content: Content) -> some View {
        content
            .environment(router)
    }
}

extension View {
    func routerStateContainer() -> some View {
        modifier(RouterStateContainerModifier())
    }
}

extension View {
    func themeStateContainer() -> some View {
        modifier(ThemeStateContainerModifier())
    }
}

struct AppStateContainer<Content: View>: View {
    @State var errorHandler = ErrorHandler()
    var modelContainer = ModelContainerFactory.createContainer()
    var content: () -> Content
    var body: some View {
        content()
            .modelContainer(modelContainer)
            .enableFeature(Feature.deepLinks)
            .routerStateContainer()
            .themeStateContainer()
            .itemStoreContainer(ItemStore(modelContainer: modelContainer, errorHandler: errorHandler))
            .errorHandler(errorHandler)
    }
}

private struct ItemStoreKey: EnvironmentKey {
    static let defaultValue: ItemStore? = nil
}

extension EnvironmentValues {
    var itemStore: ItemStore? {
        get { self[ItemStoreKey.self] }
        set { self[ItemStoreKey.self] = newValue }
    }
}

struct ItemStoreContainerModifier: ViewModifier {
    @State private var store: ItemStore
    init(_ store: ItemStore) {
        self.store = store
    }
    func body(content: Content) -> some View {
        content
            .environment(\.itemStore, store)
    }
}

private extension View {
    func itemStoreContainer(_ store: ItemStore) -> some View {
        modifier(ItemStoreContainerModifier(store))
    }
}

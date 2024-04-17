//
//  AppState.swift
//  Template
//
//  Created by Brett Meader on 02/04/2024.
//

import SwiftUI
import SwiftData

struct AppStateContainer<Content: View>: View {
    @State private var theme: AppTheme = .default
    @State private var router: AppRouter = .init()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    var content: () -> Content
    var body: some View {
        content()
            .enableFeature(Feature.deepLinks)
            .environment(router)
            .environment(\.appTheme, $theme)
            .modelContainer(sharedModelContainer)
    }
}

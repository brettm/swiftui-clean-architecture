//
//  TemplateApp.swift
//  Template
//
//  Created by Brett Meader on 21/03/2024.
//

import SwiftUI

// Image loading
// Analytics, A/B testing
// Security
// DI
// router
// Theming
// Deep-linking
// localisation
// internationalisation
// accessibility
// testing
// environment/config
// use of .inspector modifier
// error handling https://developer.apple.com/tutorials/app-dev-training/handling-errors
// networking

import SwiftData

enum ModelContainerFactory {
    static func createContainer() -> ModelContainer {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

@Observable
open class RepoMan {
    let modelContainer: ModelContainer
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
}

extension RepoMan {
    var itemsRepo: ItemRepository {
        ItemRepository(modelContainer: modelContainer)
    }
}

@main
struct TemplateApp: App {
    var modelContainer = ModelContainerFactory.createContainer()
    var body: some Scene {
        WindowGroup {
            AppStateContainer() {
                Navigator(sideBar: Routes())
            }
            .modelContainer(modelContainer)
            .environment(RepoMan(modelContainer: modelContainer))
            .foregroundStyle(AppForegroundStyle())
        }
    }
}

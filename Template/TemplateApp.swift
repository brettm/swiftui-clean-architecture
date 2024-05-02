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
// Async button

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

//@Observable
//open class RepoMan {
//    let modelContainer: ModelContainer
//    init(modelContainer: ModelContainer) {
//        self.modelContainer = modelContainer
//    }
//}

@main
struct TemplateApp: App {
    var body: some Scene {
        WindowGroup {
            AppStateContainer {
                Navigator(sideBar: Routes())
            }
            
//            .environment(RepoMan(modelContainer: modelContainer))
            .foregroundStyle(AppForegroundStyle())
            
        }
    }
}

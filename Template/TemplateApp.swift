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

@main
struct TemplateApp: App {
    var body: some Scene {
        WindowGroup {
            AppStateContainer {
                Navigator(sideBar: Routes())
            }
            .foregroundStyle(AppForegroundStyle())
        }
    }
}

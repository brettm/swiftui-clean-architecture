//
//  Router.swift
//  Template
//
//  Created by Brett Meader on 22/03/2024.
//

import SwiftUI

protocol Route: Equatable, Hashable {}

enum AppRoute: Route {
    case item(Item)
    case settings
    case none
}

struct AppNavigationState {
    var presentingRoute: AppRoute = .none
    var navigationRoutes: [AppRoute] = []
    var root: AppRoute? = nil
}

protocol AppRouterInterface {
    var navigationState: AppNavigationState { get set }
    func navigateToRoute(_ route: AppRoute)
}

@Observable
class AppRouter: AppRouterInterface {
    
    var navigationState = AppNavigationState()
    
    func navigateToRoute(_ route: AppRoute) {
        if route == .settings {
            navigationState.presentingRoute = route
            return
        }
        navigationState = AppNavigationState(root: route)
    }
}



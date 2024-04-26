//
//  DeepLinks.swift
//  Template
//
//  Created by Brett Meader on 27/03/2024.
//

import Foundation

// To test deeplinks you can use the command line tools with the following Restful URL structure:
//
// xcrun simctl openurl booted templateapp://api/
// xcrun simctl openurl booted templateapp://api/item/3
// xcrun simctl openurl booted templateapp://api/settings
//
// To test universal deeplinks you can use the command line tools with the following Restful URL structure (only supported with hosted app-link-association file):
//
// xcrun simctl openurl booted https://host/
// xcrun simctl openurl booted https://host/item/3
// xcrun simctl openurl booted https://host/settings

extension Feature {
    struct DeepLinks: KnownFeature {
        var name: String = "deepLinks"
    }
    static let deepLinks = DeepLinks()
}

extension AppRoute {
    var linkPath: String? {
        switch self {
        case .item(_): return String(localized: "item", table: "LocalisablePaths")
        case .settings: return String(localized: "settings", table: "LocalisablePaths")
        case .none: return nil
        }
    }
}

protocol AppUrlHandler {
    func handleOpenUrl(url: URL) async throws -> Bool
}

protocol AppRouteCreator {
    func route(forPath path: String, id: Int?) async -> AppRoute
}

protocol AppRouterProvider {
    var router: AppRouter { get }
}

import SwiftData

protocol AppLinksHandler: AppUrlHandler, AppRouterProvider, AppRouteCreator {
    var urlScheme: String { get }
    func item(_ id: Int) -> Item?
}

enum AppLinkError: Error {
    case malformedLink
    case unrecognisedScheme
}

// AppUrlHandler
extension AppLinksHandler {
    // TODO: read scheme from env config
    func handleOpenUrl(url: URL) async throws -> Bool {
        guard url.scheme == self.urlScheme else { throw AppLinkError.unrecognisedScheme }
        let route = try await self.route(fromPathComponents: url.pathComponents)
        self.router.navigateToRoute(route)
        return true
    }

    func route(fromPathComponents pathComponents: [String]) async throws -> AppRoute {
        var _pathComponents = pathComponents
        guard 
            !pathComponents.isEmpty,
            var component = _pathComponents.popLast()
        else { return .none }
        let id = Int(component)
        if id != nil {
            guard let path = _pathComponents.popLast() else {
                throw AppLinkError.malformedLink
            }
            component = path
        }
        return await route(forPath: component, id: id)
    }
    
    func route(forPath path: String, id: Int? = nil) async -> AppRoute {
        if path == String(localized: "item"), let id, let itemDependency = item(id)  {
            return .item(itemDependency)
        }
        else if path == String(localized: "settings") {
            return .settings
        }
        return .none
    }
}

import SwiftUI

struct AppLinksHandlerProvider<Content: View>: View, AppLinksHandler {
   
    @Environment(AppRouter.self) var router: AppRouter
    
    // TODO: Set from env value
    public var urlScheme: String = "templateapp"
    public var content: () -> Content
    
    @DataModel<Item> var items
    
    var body: some View {
        content()
            .onOpenURL { url in
                Task {
                    do {
                        _ = try await self.handleOpenUrl(url: url)
                    }
                }
            }
    }
    
    func item(_ id: Int) -> Item? {
        items.first(where: { $0.id == id })
    }
}




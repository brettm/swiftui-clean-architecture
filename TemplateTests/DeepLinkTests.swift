//
//  DeepLinkTests.swift
//  TemplateTests
//
//  Created by Brett Meader on 01/04/2024.
//

import XCTest

@testable import Template
import SwiftData

final class DeepLinkTests: XCTestCase, AppLinksHandler {
    
    var urlScheme: String = "templateapp"
    
    @MainActor func item(_ id: Int) -> Template.Item? {
        return try! self.modelContext.fetch(FetchDescriptor()).first(where: { $0.id == id })
    }
    
    var router: AppRouter = AppRouter()
    
    @MainActor
    var testModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @MainActor
    var modelContext: ModelContext {
        return testModelContainer.mainContext
    }
    
    func testInternationalisation() {
        XCTAssertTrue(AppRoute.item(Item.preview).linkPath == "item")
        XCTAssertTrue(AppRoute.settings.linkPath == "settings")
    }

    @MainActor
    func testCanOpenURL() async throws {
        
        let passID = 999
        
        testModelContainer.mainContext.insert(Item(id: passID))
        
        var test = URL(string: "templateapp://api/settings")!
        var result = try await self.handleOpenUrl(url: test )
        XCTAssertTrue(result)
        XCTAssertTrue(self.router.navigationState.presentingRoute == .settings)
        XCTAssertTrue(self.router.navigationState.root == nil)
        
        // This link is invalid so should be ignored (incorrect scheme) so the previous navigation state is expected
        test = URL(string: "gsjdjkshdfjk://api/settings")!
        do {
            result = try await self.handleOpenUrl(url: test)
        } catch {
            XCTAssertTrue(AppLinkError.unrecognisedScheme == error as! AppLinkError)
        }
        
        XCTAssertTrue(router.navigationState.presentingRoute == .settings)
        XCTAssertTrue(router.navigationState.root == nil)
        
        // This link is invalid so should be ignored (incorrect scheme) so the previous navigation state is expected
        test = URL(string: "templateapp://123456")!
        do {
            result = try await self.handleOpenUrl(url: test)
        } catch {
            XCTAssertTrue(AppLinkError.malformedLink == error as! AppLinkError)
        }
        
        XCTAssertTrue(router.navigationState.presentingRoute == .none)
        XCTAssertTrue(router.navigationState.root == AppRoute.none)
        
        // This link is valid but the path is invalid so navigation should be reset
        test = URL(string: "templateapp://api/sdfsdfsf")!
        result = try await self.handleOpenUrl(url: test)
        XCTAssertTrue(result)
        XCTAssertTrue(router.navigationState.presentingRoute == .none)
        XCTAssertTrue(router.navigationState.root == AppRoute.none)
        
        // This is a valid link with item that exists in DB
        test = URL(string: "templateapp://api/item/\(passID)")!
        result = try await self.handleOpenUrl(url: test)
        XCTAssertTrue(result)
        XCTAssertTrue(router.navigationState.presentingRoute == .none)
        XCTAssertTrue(router.navigationState.root == AppRoute.item(Item(id: passID)))
        
        // This is a valid link with item that doesn't exist in DB
        test = URL(string: "templateapp://api/item/da4bfd14-b888-48ed-ad41-4bf4ff1766aa")!
        result = try await self.handleOpenUrl(url: test)
        XCTAssertTrue(result)
        XCTAssertTrue(router.navigationState.presentingRoute == .none)
        XCTAssertTrue(router.navigationState.root == AppRoute.none)
        
        // This link is valid but the path is invalid (no item id) so navigation should be reset
        test = URL(string: "templateapp://api/item/")!
        result = try await self.handleOpenUrl(url: test)
        XCTAssertTrue(result)
        XCTAssertTrue(router.navigationState.presentingRoute == .none)
        XCTAssertTrue(router.navigationState.root == AppRoute.none)
        
        // Test for empty path components
        test = URL(string: "templateapp://api")!
        result = try await self.handleOpenUrl(url: test)
        XCTAssertTrue(result)
        XCTAssertTrue(router.navigationState.presentingRoute == .none)
        XCTAssertTrue(router.navigationState.root == AppRoute.none)
    }
}

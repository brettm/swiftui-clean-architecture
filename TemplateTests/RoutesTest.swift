//
//  RoutesTest.swift
//  TemplateTests
//
//  Created by Brett Meader on 04/04/2024.
//

import XCTest
@testable import Template
import SwiftUI
import SwiftData
import ViewInspector

@MainActor
final class RoutesTest: XCTestCase {
    
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
    
    var modelContext: ModelContext {
        return testModelContainer.mainContext
    }
    
//    lazy var modelRepo: ModelRepository = {
//        return ModelRepository(modelContext: modelContext)
//    }()

    func testRoutes() throws {
        let router: AppRouter = .init()
        let sut = Routes()
        let exp = sut.inspection.inspect { [weak self] view in
            // Test addition
            XCTAssertNoThrow(try view.find(viewWithAccessibilityIdentifier: "RoutesAddItem").button().tap())
            XCTAssert( try self?.modelContext.fetch(FetchDescriptor<Item>()).count == 1 )
            XCTAssertNoThrow(try view.find(viewWithAccessibilityIdentifier: "RoutesAddItem").button().tap())
            XCTAssert( try self?.modelContext.fetch(FetchDescriptor<Item>()).count == 2 )
            // TODO: Test deletion
        }
        ViewHosting.host(view: sut.environment(router).modelContext(modelContext))
        wait(for: [exp], timeout: 0.5)
    }
    
    func testNoneRoute() {
        let view = AnyView(AppRoute.none.view())
        ViewHosting.host(view: view)
        XCTAssertNoThrow(_ = try! view.inspect().find(UnselectedRoute.self))
    }
    
    func testItemRoute() {
        let item = Item.preview
        let view = AnyView(AppRoute.item(item).view())
        ViewHosting.host(view: view)
        XCTAssertNoThrow(_ = try! view.inspect().find(ItemDetail.self).actualView())
    }
    
    func testSettingsRoute() {
        let view = AnyView(AppRoute.settings.view())
        ViewHosting.host(view: view)
        XCTAssertNoThrow(_ = try! view.inspect().find(Settings.self).actualView())
    }
}

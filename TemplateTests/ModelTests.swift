//
//  ModelTests.swift
//  TemplateTests
//
//  Created by Brett Meader on 04/04/2024.
//

import XCTest
@testable import Template
import SwiftUI
import SwiftData
import ViewInspector

final class ModelTests: XCTestCase {

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
    
//    @MainActor
//    func testRepo() async {
//        var itemInserted = Item.preview
//        self.modelContext.insert(itemInserted)
//        let repo = ModelRepository(modelContext: self.modelContext)
//        let itemFound = await repo.item(itemInserted.id)
//        XCTAssert(itemFound == itemInserted)
//        
//        self.modelContext.insert(itemInserted)
//        var items = await repo.allItems()
//        XCTAssert(items?.count == 1)
//        
//        let id = UUID()
//        itemInserted = Item(id: id)
//        self.modelContext.insert(itemInserted)
//        items = await repo.allItems()
//        XCTAssert(items?.count == 2)
//    }
}

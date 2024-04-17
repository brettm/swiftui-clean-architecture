//
//  NavigatorTests.swift
//  TemplateTests
//
//  Created by Brett Meader on 05/04/2024.
//

import XCTest
@testable import Template

import ViewInspector
import SwiftUI

final class NavigatorTests: XCTestCase {
    
    @MainActor
    func testSettings() throws {
        let view = Navigator(sideBar: EmptyView())
        let router = AppRouter()
        let expectation = view.inspection.inspect { view in
            // Show settings (UI)
            try view.find(viewWithAccessibilityIdentifier: "NavigatorShowSettingsButton").button().tap()
            let sheet = try view.navigationSplitView().sheet()
            XCTAssertNoThrow(_ = try sheet.find(Settings.self).actualView())
            // Hide settings (Router)
            router.navigateToRoute(.none)
            XCTAssertNoThrow(_ = try view.find(UnselectedRoute.self))
            XCTAssertThrowsError( _ = try view.navigationSplitView().sheet() )
        }
        ViewHosting.host(view: view.environment(router))
        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testNavigation() throws {
        let view = Navigator(sideBar: EmptyView())
        let router = AppRouter()
        let expectation = view.inspection.inspect { view in
            let item = Item.preview
            router.navigateToRoute(.item(item))
            XCTAssertNoThrow(_ = try view.find(ItemDetail.self).actualView())
            XCTAssertThrowsError( _ = try view.find(Settings.self))
            XCTAssertThrowsError( _ = try view.find(UnselectedRoute.self))
        }
        ViewHosting.host(view: view.environment(router))
        wait(for: [expectation], timeout: 1.0)
    }

}

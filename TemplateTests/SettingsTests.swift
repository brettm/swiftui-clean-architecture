//
//  SettingsTests.swift
//  TemplateTests
//
//  Created by Brett Meader on 03/04/2024.
//

import XCTest
@testable import Template

import ViewInspector
import SwiftUI

struct TestHarnessPresenter<Content: View>: View {
    var view: Content
    @State var presentingContent: Bool = false
    var body: some View {
        Text("Settings Test Harness")
            .sheet(isPresented: $presentingContent) {
                view
            }
    }
}

final class SettingsTests: XCTestCase {

    func testSettings() throws {
        let harness = TestHarnessPresenter(view: Settings(), presentingContent: true)
        let expectation = harness.view.inspection.inspect { view in
            XCTAssertNoThrow(_ = try view.find(Settings.self).actualView())
            XCTAssert(harness.presentingContent == true)
            XCTAssertNoThrow(try view.find(viewWithAccessibilityIdentifier: "SettingsDismissButton").button().tap())
            XCTAssert(try view.actualView().presentationMode.wrappedValue.isPresented == false)
        }
        ViewHosting.host(view: harness)
        wait(for: [expectation], timeout: 0.1)
    }
}

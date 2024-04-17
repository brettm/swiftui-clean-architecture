//
//  ThemeTests.swift
//  TemplateTests
//
//  Created by Brett Meader on 04/04/2024.
//

import XCTest
@testable import Template

import ViewInspector
import SwiftUI

struct TestThemeProvider<Content: View>: View {
    var view: Content
    @State var theme: AppTheme = .default
    var body: some View {
        view
            .environment(\.appTheme, $theme)
    }
}

final class ThemeTests: XCTestCase {

    @MainActor
    func testThemeSelector() throws {
        let globalTheme = Binding<AppTheme>(wrappedValue: .default)
        let view = ThemeSelector()
        let expectation = view.inspection.inspect { view in
            for (idx, theme) in AppTheme.allCases.enumerated() {
                try view.find(viewWithAccessibilityIdentifier: "ThemeSelection_\(idx)").callOnTapGesture()
                XCTAssert(globalTheme.wrappedValue == theme)
                let suts = view.findAll(ThemeSelection.self) { selection in
                    try selection.actualView().isHighlighted
                }
                XCTAssert(suts.count == 1)
                XCTAssert(try suts.first?.accessibilityIdentifier() == "ThemeSelection_\(idx)")
            }
        }
        ViewHosting.host(view: view.environment(\.appTheme, globalTheme))
        wait(for: [expectation], timeout: 0.1)
    }
}

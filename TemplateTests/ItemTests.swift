//
//  ItemTests.swift
//  TemplateTests
//
//  Created by Brett Meader on 04/04/2024.
//

import XCTest
@testable import Template

import ViewInspector
import SwiftUI

final class ItemTests: XCTestCase {
    func testItemView() throws {
        let item = Item.preview
        let sut = ItemDetail(item: item)
        ViewHosting.host(view: sut)

        let link = try sut.inspect().find(navigationLink: "More Item Functionality -->", locale: Locale(identifier: "en"))
        XCTAssert(try link.value(AppRoute.self) == AppRoute.item(item))
    }
}

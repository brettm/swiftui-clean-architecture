//
//  Item.swift
//  Template
//
//  Created by Brett Meader on 21/03/2024.
//

import Foundation
import SwiftData

@Model
final class Item: Identifiable, Equatable, Hashable {
    var id: UUID
    var timestamp: Date
    init(id: UUID, timestamp: Date = Date.now) {
        self.id = id
        self.timestamp = timestamp
    }
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}

extension Item {
    static var preview: Item = {
        var id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        var timestamp = Date(timeIntervalSince1970: 0)
        return Item(id: id, timestamp: timestamp)
    }()
}


//
//  DataModel.swift
//  Template
//
//  Created by Brett Meader on 11/04/2024.
//

import SwiftUI
import SwiftData

// Convenience generic property wrapper for manipulating the data model
// from SwiftUI
@propertyWrapper struct DataModel<T: PersistentModel>: DynamicProperty {
    var wrappedValue: [T] { values }
    @Environment(\.modelContext) private var modelContext
    @Query private var values: [T]
}

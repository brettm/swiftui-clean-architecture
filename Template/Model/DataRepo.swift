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
@propertyWrapper struct DataRepo<T: PersistentModel>: DynamicProperty {
    var wrappedValue: [T] { values }
    @Environment(\.modelContext) var modelContext
    @Query private var values: [T]
    
    public func add(_ model: T) {
        modelContext.insert(model)
    }
    func delete(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(values[index])
        }
    }
}

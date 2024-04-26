//
//  Respository.swift
//  Template
//
//  Created by Brett Meader on 23/04/2024.
//

import SwiftData
import SwiftUI
import ItemsAPIClient

protocol Repository<T> {
    associatedtype T
    associatedtype C
    func fetchAll() async throws -> [T]
    func create(_ entity: T) async throws -> T
    func update(_ entity: T) async -> T?
    func delete(_ entity: T) async -> T?
}

protocol ModelSyncRepository: Sendable, Repository where T: PersistentModel {
    associatedtype Client: APIClientServerProvider
    var client: Client { get }
    var modelContainer: ModelContainer { get }
}

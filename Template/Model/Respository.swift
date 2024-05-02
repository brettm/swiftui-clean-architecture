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
    associatedtype Id
    func fetchAll() async throws -> [T]
    func create(_ entity: T) async throws -> T
    func update(_ entity: T) async throws -> T?
    func delete(_ entityId: Id) async throws -> T?
}

protocol ModelSyncRepository: Repository where T: PersistentModel {
    associatedtype Client: APIClientServiceFetching
    var client: Client { get }
//    var modelContainer: ModelContainer { get }
    var modelContext: ModelContext { get }
    
    static func translate(apiResponseItem item: APIResponseItem?) -> [T]
}

extension ModelSyncRepository {
    @discardableResult
    func fetchAll() async throws -> [T] {
//        let modelContext = ModelContext(self.modelContainer)
        let response = try await client.fetch(parameters: [])
        switch response {
        case .success(let responseBody):
            let models = Self.translate(apiResponseItem: responseBody)
            try modelContext.delete(model: Item.self)
            _ = models.map{ modelContext.insert($0) }
            try modelContext.save()
            return models
        case .failure(let error):
            throw error
        }
    }
}



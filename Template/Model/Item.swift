//
//  Item.swift
//  Template
//
//  Created by Brett Meader on 21/03/2024.
//

import Foundation
import SwiftData
import ItemsAPIClient

@Model
final class Item: Identifiable, Equatable, Hashable {
    @Attribute(.unique) var id: Int
    var timestamp: Date
    fileprivate init(id: Int, timestamp: Date = Date.now) {
        self.id = id
        self.timestamp = timestamp
    }
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}

extension Item {
    static var new: Item {
        Item(id: 0)
    }
    
    static var preview: Item = {
        var id = 1
        var timestamp = Date(timeIntervalSince1970: 0)
        return Item(id: id, timestamp: timestamp)
    }()
}

extension Item {
    convenience init(fromApiModel model: APIItemResponseItem) {
        self.init(id: model.id, timestamp: Date(timeIntervalSince1970: TimeInterval(model.timestamp)))
    }
}

extension APIItemResponseItem {
    var dataItem: Item {
        return Item(fromApiModel: self)
    }
}

extension APIItemsResponseItem {
    var dataItems: [Item] {
        return items.map { $0.dataItem }
    }
}

struct ItemRepository: ModelSyncRepository {
    var modelContext: ModelContext
    
    typealias T = Item
    typealias Id = Int
    
    var client = ItemAPIClient(server: APIServer.server1)
    
    static func translate(apiResponseItem item: APIResponseItem?) -> [Item] {
        if let itemsResponse = item as? APIItemsResponseItem {
            return itemsResponse.dataItems
        }
        else if let itemResponse = item as? APIItemResponseItem {
            return [itemResponse.dataItem]
        }
        return []
    }
    
    @discardableResult
    func create(_ entity: T) async throws -> T {
        let timeStamp = APITimestampRequestItem(integerLiteral: Int(entity.timestamp.timeIntervalSince1970))
        let request: APIRequest = .init( timeStamp )
        let response = try await client.create(request)
        switch response {
        case .success(let responseBody):
            if let data = Self.translate(apiResponseItem: responseBody).first {
                modelContext.insert(data)
                try modelContext.save()
                return data
            }
        case .failure(let error):
            throw error
        }
        return entity
    }
    
    @discardableResult
    func update(_ entity: T) -> T? {
        fatalError("Item client doesn't yet support update")
    }
    
    @discardableResult
    func delete(_ entityId: Id) async throws -> T? {
        guard let entity = try modelContext.fetch(FetchDescriptor<T>(predicate: #Predicate { $0.id == entityId })).first else {
            return nil
        }
        let request: APIRequest = .init( APIItemIdsRequestItem( [entityId] ) )
        let response = try await client.delete(request)
        switch response {
        case .success(_):
            modelContext.delete(entity)
            try modelContext.save()
        case .failure(let error):
            throw error
        }
        return nil
    }
}

struct ItemStore {
    internal init(modelContainer: ModelContainer, errorHandler: ErrorHandler) {
        self.modelContainer = modelContainer
        self.errorHandler = errorHandler
    }
    
    private var modelContainer: ModelContainer
    private var errorHandler: ErrorHandler
    private var newBackgroundContext: ModelContext {
        ModelContext(modelContainer)
    }
    
    func updateAll() {
        Task.detached(priority: .background) {
            let itemRepo = ItemRepository(modelContext: newBackgroundContext)
            _ = try! await itemRepo.fetchAll()
        }
    }
    
    func addItem(_ item: APIItemRequestItem) {
        Task.detached(priority: .background) {
            let itemRepo = ItemRepository(modelContext: newBackgroundContext)
            do {
                _ = try await itemRepo.create(Item.new)
            } catch {
                await errorHandler.handleError(error: error) {
                    Task {  @MainActor in
                        addItem(item)
                    }
                }
            }
        }
    }
    
    func deleteItem(itemId id: Int) {
        Task.detached(priority: .background) {
            let itemRepo = ItemRepository(modelContext: newBackgroundContext)
            do {
                _ = try await itemRepo.delete( id )
            } catch {
                await errorHandler.handleError(error: error) {
                    Task {  @MainActor in
                        deleteItem(itemId: id)
                    }
                }
            }
        }
    }
}


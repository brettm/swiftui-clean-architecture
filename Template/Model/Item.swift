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
    typealias T = Item
    typealias C = Predicate<Item>
    
    var client = ItemAPIClient(server: ItemAPIServers.server1)
    let modelContainer: ModelContainer
    
    static func translate(apiResponseItem item: APIResponseItem?) -> [Item] {
        if let itemsResponse = item as? APIItemsResponseItem {
            return itemsResponse.dataItems
        }
        else if let itemResponse = item as? APIItemResponseItem {
            return [itemResponse.dataItem]
        }
        return []
    }
    
    func read(_ criteria: Predicate<Item>) -> T? {
        return nil
    }
    
    @discardableResult
    func fetchAll() async throws -> [T] {
        let modelContext = ModelContext(self.modelContainer)
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
    
    @discardableResult
    func create(_ entity: T) async throws -> T {
        let modelContext = ModelContext(self.modelContainer)
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
    func delete(_ entity: T) -> T? {
        let modelContext = ModelContext(self.modelContainer)
//        modelContext.delete
        // TODO: Delete with ID
        try! modelContext.save()
        return nil
    }
}

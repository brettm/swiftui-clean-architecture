//
//  HomeView.swift
//  Template
//
//  Created by Brett Meader on 21/03/2024.
//

import SwiftUI
import SwiftData
import ItemsAPIClient

struct Routes: View {
   
    let inspection = Inspection<Self>()
    
    @Environment(AppRouter.self) private var router
    
    @DataModel<Item> private var itemData
    @Environment(\.itemStore) private var itemStore
    
    @State private var selectedRoute: AppRoute?
    
    var body: some View {
        List(selection: $selectedRoute) {
            ForEach(itemData) { item in
                ItemRouteView(item: item)
                    .tag( AppRoute.item(item) )
            }
            .onDelete(perform: deleteItems(offsets:) )
        }
        .animation(.default, value: itemData)
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .accessibilityIdentifier("RoutesEditItem")
            }
#endif
            ToolbarItem {
                Button(action: addItem ) {
                    Label("Add Item", systemImage: "plus")
                }
                .accessibilityIdentifier("RoutesAddItem")
            }
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onAppear { itemStore?.updateAll() }
        .onChange(of: selectedRoute) { _, newValue in
            if let newValue { router.navigateToRoute(newValue) }
        }
    }
    
    private func addItem() {
        itemStore?.addItem(APIItemRequestItem(id: -1, timestamp: Int(Date().timeIntervalSince1970)))
    }

    private func deleteItems(offsets: IndexSet) {
        _ = offsets.map { itemStore?.deleteItem(itemId: itemData[$0].id) }
    }
}

#Preview {
    Routes()
        .modelContainer(for: Item.self, inMemory: true)
}

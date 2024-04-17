//
//  HomeView.swift
//  Template
//
//  Created by Brett Meader on 21/03/2024.
//

import SwiftUI
import SwiftData

struct Routes: View {
   
    let inspection = Inspection<Self>()
    
    @Environment(AppRouter.self) private var router
    @DataRepo<Item> private var itemRepo
    
    var body: some View {
        @Bindable var router = router
        List(selection: $router.navigationState.root) {
            ForEach(itemRepo) { item in
                ItemRoute(item: item)
            }
            .onDelete(perform: deleteItems(offsets:))
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                    .accessibilityIdentifier("RoutesEditItem")
            }
#endif
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
                .accessibilityIdentifier("RoutesAddItem")
            }
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(id: UUID(), timestamp: Date())
            _itemRepo.add(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            _itemRepo.delete(offsets: offsets)
        }
    }
}

#Preview {
    Routes()
        .modelContainer(for: Item.self, inMemory: true)
}

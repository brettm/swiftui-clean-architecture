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
    
    @DataModel<Item> private var itemData
    @Environment(RepoMan.self) var repoMan
    
    var body: some View {
        @Bindable var router = router
        List(selection: $router.navigationState.root) {
            ForEach(itemData) { item in
                ItemRoute(item: item)
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
        .onAppear {
            self.fetchData()
        }
    }
    
    private func addItem() {
        let itemRepo = repoMan.itemsRepo
        Task {
            _ = try! await itemRepo.create(Item.new)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        let itemRepo = repoMan.itemsRepo
        for index in offsets {
            _ = itemRepo.delete(itemData[index])
        }
    }
    
    private func fetchData() {
        let itemRepo = repoMan.itemsRepo
        Task {
            _ = try! await itemRepo.fetchAll()
        }
    }
}

#Preview {
    Routes()
        .modelContainer(for: Item.self, inMemory: true)
}

//
//  Item.swift
//  Template
//
//  Created by Brett Meader on 26/03/2024.
//

import SwiftUI

struct ItemDetail: View {
    var item: Item
    var body: some View {
        VStack {
            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
            Text("Item ID : \(item.id)")
            NavigationLink(value: AppRoute.item(item)) {
                Text("More Item Functionality -->")
            }
        }
        .onAppear {
            print(item.id)
        }
    }
}

struct ItemRoute: View {
    var item: Item
    var body: some View {
        HStack {
            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
        }
        .tag(AppRoute.item(item))
    }
}


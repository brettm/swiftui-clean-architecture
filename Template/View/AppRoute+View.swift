//
//  Factory.swift
//  Template
//
//  Created by Brett Meader on 26/03/2024.
//
import SwiftUI

internal struct UnselectedRoute: View {
    var body: some View {
        Text("Selecta root route")
    }
}

extension AppRoute {
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .item(let item): ItemDetail(item: item)
        case .settings: Settings()
        case .none: UnselectedRoute() }
    }
}


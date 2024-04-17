//
//  Inspectable.swift
//  Template
//
//  Created by Brett Meader on 13/04/2024.
//

import SwiftUI

extension View {
    func applyInspection<V: Inspectable>(_ view: V) -> some View {
        onReceive(view.inspection.notice) {
            view.inspection.visit(view, $0)
        }
    }
}

protocol Inspectable: View {
    associatedtype InspectedBody: View
    var inspection: Inspection<Self> { get }
    @ViewBuilder @MainActor var inspectedBody: InspectedBody { get }
}

extension Inspectable {
    @ViewBuilder @MainActor var body: some View {
        inspectedBody.applyInspection(self)
    }
}

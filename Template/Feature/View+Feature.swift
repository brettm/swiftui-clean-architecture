//
//  View+Feature.swift
//  Template
//
//  Created by Brett Meader on 01/04/2024.
//

import SwiftUI

extension View {
    @ViewBuilder
    func enableFeature(_ feature: KnownFeature) -> some View {
        if feature as? Feature.DeepLinks != nil {
            AppLinksHandlerProvider {
                self
            }
        }
    }
}

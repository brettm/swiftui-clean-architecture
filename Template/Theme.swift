//
//  Theme.swift
//  Template
//
//  Created by Brett Meader on 21/03/2024.
//

import SwiftUI

enum AppTheme: String, CaseIterable {
    case `default`
    case mint
    case bananas
    case cherry
    case poopies
}

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: Binding<AppTheme> = .constant(.default)
}

extension EnvironmentValues {
    var appTheme: Binding<AppTheme> {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

enum AppStyleFactory {
    static func shapeStyle(_ theme: AppTheme) -> some ShapeStyle {
        return switch theme {
        case .default: Color.init("ForegroundDefault")
        case .mint: Color.init("ForegroundMint")
        case .bananas: Color.init("ForegroundBananas")
        case .cherry: Color.red
        case .poopies: Color.brown
        }
    }
}

struct AppForegroundStyle: ShapeStyle {
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        return AppStyleFactory.shapeStyle(environment.appTheme.wrappedValue)
    }
}


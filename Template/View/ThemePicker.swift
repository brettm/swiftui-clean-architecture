//
//  ThemePicker.swift
//  Template
//
//  Created by Brett Meader on 01/05/2024.
//

import SwiftUI

struct ThemePicker: View {
    @Environment(\.appTheme) var appTheme
    internal let inspection = Inspection<Self>()
    var body: some View {
        VStack {
            HStack {
                Text("App theme")
                Spacer()
                HStack {
                    ForEach(Array(AppTheme.allCases.enumerated()), id: \.element) { idx, theme in
                        ThemeSelection(
                            isHighlighted: theme == appTheme.wrappedValue,
                            title: theme.rawValue,
                            titleAlignment: theme == .allCases.last ? .bottomTrailing : .bottom,
                            titleOffset: .init(width: 0, height: 22)
                        )
                            .frame(maxHeight: 30)
                            .padding([.top], 8.0)
                            .padding([.bottom], 20.0)
                            .padding([.leading], 4.0)
                            .foregroundStyle(AppStyleFactory.shapeStyle(theme))
                            .onTapGesture { appTheme.wrappedValue = theme }
                            .accessibilityIdentifier("ThemeSelection_\(idx)")
                    }
                }
            }
        }
        .padding(8)
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

struct ThemeSelection: View {
    var isHighlighted: Bool = false
    var title: String = ""
    var titleAlignment: Alignment = .bottom
    var titleOffset: CGSize = .init(width: 0, height: 10)
    var body: some View {
        if isHighlighted {
            Circle()
                .overlay(alignment: .center) {
                    Circle()
                        .foregroundStyle(.white)
                        .frame(maxHeight: 12.0)
                        .shadow(color: .black, radius: 1.0)
                }
                .overlay(alignment: titleAlignment) {
                    Text(title)
                        .fixedSize()
                        .offset(titleOffset)
                }
        }
        else {
            Circle()
        }
    }
}

#Preview {
    ThemePicker()
        .themeStateContainer()
        .frame(maxWidth: 320)
}

//
//  SettingsView.swift
//  Template
//
//  Created by Brett Meader on 22/03/2024.
//

import SwiftUI

struct Settings: View {
    @Environment(\.presentationMode) var presentationMode
    internal let inspection = Inspection<Self>()
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Theme")) {
                    ThemePicker()
                }
            }
            .formStyle(.grouped)
            .padding()
            .toolbar {
                ToolbarItem {
                    Button("Dismiss", systemImage: "xmark.circle") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .accessibilityIdentifier("SettingsDismissButton")
                }
            }
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

#Preview {
    Settings()
}

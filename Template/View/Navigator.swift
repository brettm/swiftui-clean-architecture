//
//  Navigator.swift
//  Template
//
//  Created by Brett Meader on 25/03/2024.
//

import SwiftUI

struct Navigator<SideBar: View>: View {
    
    @Environment(AppRouter.self) var router
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    
    internal let inspection = Inspection<Self>()
    var sideBar: SideBar
    
    var body: some View {
        @Bindable var router = router
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sideBar
                .toolbar(removing: router.navigationState.navigationRoutes.count > 0 ? .sidebarToggle : .none)
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            router.navigateToRoute(.settings)
                        }, label: {
                            Label("Show Settings", systemImage: "gearshape")
                        })
                        .accessibilityIdentifier("NavigatorShowSettingsButton")
                    }
                }
        }
        detail: {
            NavigationStack(path: $router.navigationState.navigationRoutes) {
                if let route = router.navigationState.root {
                    route.view()
                        .navigationDestination(for: AppRoute.self) { route in
                            route.view()
                        }
                }
                else {
                    AppRoute.none.view()
                }
            }
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 220, ideal: 250)
#endif
        .sheet2(isPresented:
                Binding(
                    get: { router.navigationState.presentingRoute != .none },
                    set: { presented,_ in
                        if !presented {
                            router.navigationState.presentingRoute = .none
                        }
                    }
                )
        , onDismiss: {
            router.navigationState.presentingRoute = .none
        }, content: {
            router.navigationState.presentingRoute.view()
                .frame(minWidth: 320)
        })
        .onChange(of: router.navigationState.navigationRoutes) {
            withAnimation {
                let detailStackCount = router.navigationState.navigationRoutes.count
                columnVisibility = detailStackCount > 0 ? .detailOnly : .automatic
            }
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

#Preview {
    Navigator(sideBar: Routes())
}

//
//  ContentView.swift
//  MarkdownViewer
//
//  Main view with three-pane layout: file picker, file tree, and content.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        @Bindable var bindableState = appState

        NavigationSplitView(
            columnVisibility: $columnVisibility
        ) {
            // Left sidebar: File picker
            FilePickerView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        } content: {
            // Middle pane: File tree
            FileTreeView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: 400)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: toggleSidebar) {
                            Label("Toggle Sidebar", systemImage: "sidebar.left")
                        }
                        .help("Show/Hide Directory Selector")
                    }
                }
        } detail: {
            // Right pane: Markdown content
            MarkdownContentView()
        }
        .onChange(of: appState.rootURL) { oldValue, newValue in
            // Auto-hide sidebar when directory is selected
            if newValue != nil && oldValue == nil {
                columnVisibility = .doubleColumn
            }
        }
    }

    private func toggleSidebar() {
        withAnimation {
            if columnVisibility == .all {
                columnVisibility = .doubleColumn
            } else {
                columnVisibility = .all
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .frame(width: 1200, height: 800)
}

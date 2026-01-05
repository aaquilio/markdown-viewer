//
//  MarkdownViewerApp.swift
//  MarkdownViewer
//
//  Main application entry point for the Markdown Viewer.
//

import SwiftUI

@main
struct MarkdownViewerApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .printItem) {
                Button("Print...") {
                    appState.printCurrentDocument()
                }
                .keyboardShortcut("p", modifiers: .command)
                .disabled(appState.selectedFile == nil)
            }
        }
    }
}

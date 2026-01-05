//
//  MarkdownContentView.swift
//  MarkdownViewer
//
//  Right pane displaying the rendered markdown content.
//

import SwiftUI
import WebKit

struct MarkdownContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if let selectedFile = appState.selectedFile {
                VStack(spacing: 0) {
                    // Header with file name
                    HStack {
                        Image(systemName: "doc.text")
                        Text(selectedFile.name)
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            appState.printCurrentDocument()
                        }) {
                            Image(systemName: "printer")
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)
                        .help("Print (⌘P)")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))

                    Divider()

                    // Content area - rendered HTML
                    if !appState.htmlContent.isEmpty {
                        MarkdownWebView(htmlContent: appState.htmlContent) { webView in
                            appState.currentWebView = webView
                        }
                        .contextMenu {
                            Button("Print...") {
                                appState.printCurrentDocument()
                            }
                        }
                    } else if appState.isLoading {
                        ProgressView("Loading...")
                    } else {
                        Text("No content")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No File Selected",
                    systemImage: "doc.text",
                    description: Text("Select a markdown file from the file tree")
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MarkdownContentView()
        .environment(AppState())
}

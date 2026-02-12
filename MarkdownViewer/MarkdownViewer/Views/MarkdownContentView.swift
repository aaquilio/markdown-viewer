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
    @State private var showSearchBar: Bool = false
    @FocusState private var searchFieldFocused: Bool

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

                        // Search toggle button
                        Button(action: {
                            showSearchBar.toggle()
                            if showSearchBar {
                                searchFieldFocused = true
                            } else {
                                appState.clearSearch()
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .imageScale(.large)
                                .foregroundStyle(showSearchBar ? .blue : .primary)
                        }
                        .buttonStyle(.plain)
                        .help("Find in Page (⌘F)")
                        .keyboardShortcut("f", modifiers: .command)

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

                    // Search bar
                    if showSearchBar {
                        SearchBarView(
                            searchText: Binding(
                                get: { appState.searchText },
                                set: { appState.search(for: $0) }
                            ),
                            currentMatch: appState.currentMatchIndex,
                            totalMatches: appState.totalMatches,
                            onNext: { appState.findNext() },
                            onPrevious: { appState.findPrevious() },
                            onClose: {
                                showSearchBar = false
                                appState.clearSearch()
                            }
                        )
                        .focused($searchFieldFocused)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.05))
                    }

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

// MARK: - Search Bar Component

struct SearchBarView: View {
    @Binding var searchText: String
    let currentMatch: Int
    let totalMatches: Int
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .imageScale(.small)

                TextField("Find in page", text: $searchText)
                    .textFieldStyle(.plain)
                    .frame(minWidth: 200)

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .imageScale(.small)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(6)

            // Match count
            if totalMatches > 0 {
                Text("\(currentMatch) of \(totalMatches)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 60)
            } else if !searchText.isEmpty {
                Text("No matches")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 60)
            }

            // Navigation buttons
            HStack(spacing: 4) {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.up")
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
                .disabled(totalMatches == 0)
                .help("Previous (⇧⌘G)")
                .keyboardShortcut("g", modifiers: [.command, .shift])

                Button(action: onNext) {
                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
                .disabled(totalMatches == 0)
                .help("Next (⌘G)")
                .keyboardShortcut("g", modifiers: .command)
            }
            .padding(.horizontal, 4)

            // Close button
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .imageScale(.small)
            }
            .buttonStyle(.plain)
            .help("Close (Esc)")
            .keyboardShortcut(.escape)
        }
    }
}

#Preview {
    MarkdownContentView()
        .environment(AppState())
}

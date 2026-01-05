//
//  FileTreeView.swift
//  MarkdownViewer
//
//  Middle pane displaying the file tree of markdown files.
//

import SwiftUI

struct FileTreeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        List(selection: Binding(
            get: { appState.selectedFile },
            set: { if let file = $0 { appState.selectFile(file) } }
        )) {
            ForEach(appState.fileTree) { item in
                FileTreeRow(item: item)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Files")
        .overlay {
            if appState.fileTree.isEmpty && appState.rootURL != nil {
                ContentUnavailableView(
                    "No Markdown Files",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("No .md files found in the selected directory")
                )
            } else if appState.rootURL == nil {
                ContentUnavailableView(
                    "No Directory Selected",
                    systemImage: "folder.badge.questionmark",
                    description: Text("Select a directory to view markdown files")
                )
            }
        }
    }
}

struct FileTreeRow: View {
    let item: FileItem

    var body: some View {
        if item.isDirectory, let children = item.children, !children.isEmpty {
            DisclosureGroup {
                ForEach(children) { child in
                    FileTreeRow(item: child)
                }
            } label: {
                Label(item.name, systemImage: "folder.fill")
                    .foregroundStyle(.secondary)
            }
        } else if !item.isDirectory {
            Label(item.name, systemImage: "doc.text.fill")
                .tag(item)
        }
    }
}

#Preview {
    NavigationStack {
        FileTreeView()
            .environment(AppState())
    }
}

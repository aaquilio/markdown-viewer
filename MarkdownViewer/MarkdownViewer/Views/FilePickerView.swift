//
//  FilePickerView.swift
//  MarkdownViewer
//
//  Left sidebar for selecting a directory.
//

import SwiftUI

struct FilePickerView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 16) {
            if let rootURL = appState.rootURL {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Directory")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(rootURL.lastPathComponent)
                        .font(.headline)
                        .lineLimit(2)
                        .truncationMode(.middle)

                    Text(rootURL.path)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(3)
                        .truncationMode(.middle)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

                Divider()
            } else {
                Text("No directory selected")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding()
            }

            Button(action: selectDirectory) {
                Label("Select Directory", systemImage: "folder.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            if appState.isLoading {
                ProgressView("Loading files...")
                    .padding()
            }

            if let errorMessage = appState.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Markdown Viewer")
        .toolbar(removing: .sidebarToggle)
    }

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.message = "Select a directory containing markdown files"

        if panel.runModal() == .OK, let url = panel.url {
            appState.loadDirectory(url)
        }
    }
}

#Preview {
    NavigationStack {
        FilePickerView()
            .environment(AppState())
    }
}

//
//  AppState.swift
//  MarkdownViewer
//
//  Central state management for the application.
//

import Foundation
import Observation
import WebKit

@Observable
class AppState {
    var rootURL: URL?
    var selectedFile: FileItem?
    var fileTree: [FileItem] = []
    var markdownContent: String = ""
    var htmlContent: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var currentWebView: WKWebView?

    private let fileWatcher = FileWatcher()

    init() {
        // Set up file watcher callback
        fileWatcher.onFileChange = { [weak self] in
            self?.reloadCurrentFile()
        }
    }

    /// Loads markdown files from the selected directory
    func loadDirectory(_ url: URL) {
        isLoading = true
        errorMessage = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let files = FileItem.loadMarkdownFiles(from: url)
            let tree = FileItem.buildTree(from: files, rootURL: url)

            DispatchQueue.main.async {
                self?.rootURL = url
                self?.fileTree = tree
                self?.isLoading = false

                // Auto-select first file if available
                if let firstFile = tree.first(where: { !$0.isDirectory }) {
                    self?.selectFile(firstFile)
                } else if let firstDir = tree.first,
                          let firstChild = firstDir.children?.first(where: { !$0.isDirectory }) {
                    self?.selectFile(firstChild)
                }
            }
        }
    }

    /// Selects a file and loads its content
    func selectFile(_ file: FileItem) {
        guard !file.isDirectory else { return }

        selectedFile = file
        loadFileContent(file.url)

        // Start watching the file for changes
        fileWatcher.watch(url: file.url)
    }

    /// Loads the content of a markdown file
    private func loadFileContent(_ url: URL) {
        isLoading = true
        errorMessage = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                let html = try MarkdownRenderer.render(markdown: content)

                DispatchQueue.main.async {
                    self?.markdownContent = content
                    self?.htmlContent = html
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to load file: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }
        }
    }

    /// Reloads the current file (for file watching)
    func reloadCurrentFile() {
        if let selectedFile = selectedFile {
            loadFileContent(selectedFile.url)
        }
    }

    /// Prints the currently displayed markdown document
    func printCurrentDocument() {
        guard let webView = currentWebView else {
            print("No web view available for printing")
            return
        }

        // Get the filename without extension for PDF export
        let suggestedFilename: String?
        if let selectedFile = selectedFile {
            // Remove the file extension and use base name
            let filename = selectedFile.url.deletingPathExtension().lastPathComponent
            suggestedFilename = filename
        } else {
            suggestedFilename = nil
        }

        PrintService.print(webView: webView, suggestedFilename: suggestedFilename)
    }
}

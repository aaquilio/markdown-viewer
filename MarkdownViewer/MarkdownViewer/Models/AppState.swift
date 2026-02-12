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

    // Search state
    var searchText: String = ""
    var currentMatchIndex: Int = 0
    var totalMatches: Int = 0
    var isSearching: Bool = false

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
            let tree = FileItem.buildTree(from: url)

            DispatchQueue.main.async {
                self?.rootURL = url
                self?.fileTree = tree
                self?.isLoading = false

                // Auto-select first file if available
                if let firstFile = self?.findFirstMarkdownFile(in: tree) {
                    self?.selectFile(firstFile)
                }
            }
        }
    }

    /// Recursively finds the first markdown file in the tree
    private func findFirstMarkdownFile(in items: [FileItem]) -> FileItem? {
        for item in items {
            if item.isMarkdown {
                return item
            }
            if let children = item.children,
               let found = findFirstMarkdownFile(in: children) {
                return found
            }
        }
        return nil
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

    // MARK: - Search Functions

    /// Performs search in the current web view
    func search(for text: String) {
        guard let webView = currentWebView, !text.isEmpty else {
            clearSearch()
            return
        }

        searchText = text
        isSearching = true

        SearchService.search(in: webView, text: text) { [weak self] matchIndex, totalMatches in
            DispatchQueue.main.async {
                self?.currentMatchIndex = matchIndex
                self?.totalMatches = totalMatches
            }
        }
    }

    /// Finds next occurrence
    func findNext() {
        guard let webView = currentWebView, !searchText.isEmpty else { return }

        SearchService.findNext(in: webView) { [weak self] matchIndex, totalMatches in
            DispatchQueue.main.async {
                self?.currentMatchIndex = matchIndex
                self?.totalMatches = totalMatches
            }
        }
    }

    /// Finds previous occurrence
    func findPrevious() {
        guard let webView = currentWebView, !searchText.isEmpty else { return }

        SearchService.findPrevious(in: webView) { [weak self] matchIndex, totalMatches in
            DispatchQueue.main.async {
                self?.currentMatchIndex = matchIndex
                self?.totalMatches = totalMatches
            }
        }
    }

    /// Clears search highlights
    func clearSearch() {
        guard let webView = currentWebView else { return }

        searchText = ""
        currentMatchIndex = 0
        totalMatches = 0
        isSearching = false

        SearchService.clearSearch(in: webView)
    }
}

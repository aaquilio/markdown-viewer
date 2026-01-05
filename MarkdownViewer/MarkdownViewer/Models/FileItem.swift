//
//  FileItem.swift
//  MarkdownViewer
//
//  Represents a file or directory in the file tree.
//

import Foundation

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let isDirectory: Bool
    var children: [FileItem]?

    var name: String {
        url.lastPathComponent
    }

    var isMarkdown: Bool {
        !isDirectory && url.pathExtension.lowercased() == "md"
    }

    /// Creates a FileItem from a URL
    init(url: URL) {
        self.url = url
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        self.isDirectory = isDir.boolValue

        if isDirectory {
            self.children = []
        }
    }

    /// Recursively loads markdown files from a directory
    static func loadMarkdownFiles(from url: URL) -> [FileItem] {
        var items: [FileItem] = []

        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return items
        }

        for case let fileURL as URL in enumerator {
            // Only include .md files
            if fileURL.pathExtension.lowercased() == "md" {
                items.append(FileItem(url: fileURL))
            }
        }

        // Sort by path for consistent ordering
        return items.sorted { $0.url.path < $1.url.path }
    }

    /// Builds a hierarchical tree structure from flat list
    static func buildTree(from items: [FileItem], rootURL: URL) -> [FileItem] {
        var tree: [FileItem] = []
        var directoryMap: [URL: FileItem] = [:]

        // First pass: create all directories
        for item in items {
            var currentURL = item.url.deletingLastPathComponent()

            while currentURL.path.hasPrefix(rootURL.path) && currentURL != rootURL {
                if directoryMap[currentURL] == nil {
                    var dirItem = FileItem(url: currentURL)
                    dirItem.children = []
                    directoryMap[currentURL] = dirItem
                }
                currentURL = currentURL.deletingLastPathComponent()
            }
        }

        // Second pass: build hierarchy
        for item in items {
            let parentURL = item.url.deletingLastPathComponent()

            if parentURL == rootURL {
                tree.append(item)
            } else if var parent = directoryMap[parentURL] {
                parent.children?.append(item)
                directoryMap[parentURL] = parent
            }
        }

        // Third pass: add directories to tree
        for (url, var dir) in directoryMap {
            let parentURL = url.deletingLastPathComponent()

            // Sort children
            dir.children?.sort { $0.name < $1.name }

            if parentURL == rootURL {
                tree.append(dir)
            } else if var parent = directoryMap[parentURL] {
                parent.children?.append(dir)
                directoryMap[parentURL] = parent
            }
        }

        return tree.sorted { item1, item2 in
            // Directories first, then files
            if item1.isDirectory != item2.isDirectory {
                return item1.isDirectory
            }
            return item1.name < item2.name
        }
    }
}

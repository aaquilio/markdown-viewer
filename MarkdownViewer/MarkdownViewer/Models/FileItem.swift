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

    /// Recursively builds a file tree starting from a directory
    static func buildTree(from url: URL) -> [FileItem] {
        return buildTreeRecursive(url: url)
    }

    /// Helper method to recursively build tree structure
    private static func buildTreeRecursive(url: URL) -> [FileItem] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var items: [FileItem] = []

        for itemURL in contents {
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDir)

            if isDir.boolValue {
                // It's a directory - recursively build its children
                var dirItem = FileItem(url: itemURL)
                dirItem.children = buildTreeRecursive(url: itemURL)

                // Only include directory if it has .md files in it (directly or in subdirs)
                if hasMarkdownFiles(in: dirItem) {
                    items.append(dirItem)
                }
            } else if itemURL.pathExtension.lowercased() == "md" {
                // It's a markdown file
                items.append(FileItem(url: itemURL))
            }
        }

        // Sort: directories first, then alphabetically by name
        return items.sorted { item1, item2 in
            if item1.isDirectory != item2.isDirectory {
                return item1.isDirectory
            }
            return item1.name.localizedCaseInsensitiveCompare(item2.name) == .orderedAscending
        }
    }

    /// Checks if a directory (or its subdirectories) contains any markdown files
    private static func hasMarkdownFiles(in item: FileItem) -> Bool {
        if item.isMarkdown {
            return true
        }

        if let children = item.children {
            return children.contains { hasMarkdownFiles(in: $0) }
        }

        return false
    }

    /// Legacy method for compatibility - now just calls buildTree
    static func loadMarkdownFiles(from url: URL) -> [FileItem] {
        // This method is no longer needed but kept for compatibility
        // The new buildTree handles everything recursively
        return []
    }

    /// Legacy method for compatibility - now unused
    static func buildTree(from items: [FileItem], rootURL: URL) -> [FileItem] {
        // This signature is no longer used, but kept for compatibility
        // Use buildTree(from: URL) instead
        return []
    }
}

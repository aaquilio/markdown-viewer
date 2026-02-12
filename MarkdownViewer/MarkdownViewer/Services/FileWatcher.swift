//
//  FileWatcher.swift
//  MarkdownViewer
//
//  Watches a file for changes and notifies when it's modified.
//

import Foundation

class FileWatcher {
    private var fileDescriptor: CInt = -1
    private var source: DispatchSourceFileSystemObject?
    private let queue = DispatchQueue(label: "com.markdownviewer.filewatcher")

    var onFileChange: (() -> Void)?

    /// Starts watching a file for changes
    func watch(url: URL) {
        // Stop any existing watch
        stop()

        // Open the file for reading
        let path = url.path
        fileDescriptor = open(path, O_EVTONLY)

        guard fileDescriptor >= 0 else {
            print("Failed to open file for watching: \(path)")
            return
        }

        // Create a dispatch source to monitor the file
        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename],
            queue: queue
        )

        source?.setEventHandler { [weak self] in
            // File was modified
            DispatchQueue.main.async {
                self?.onFileChange?()
            }
        }

        source?.setCancelHandler { [weak self] in
            guard let self = self, self.fileDescriptor >= 0 else { return }
            close(self.fileDescriptor)
            self.fileDescriptor = -1
        }

        source?.resume()
    }

    /// Stops watching the current file
    func stop() {
        source?.cancel()
        source = nil

        if fileDescriptor >= 0 {
            close(fileDescriptor)
            fileDescriptor = -1
        }
    }

    deinit {
        stop()
    }
}

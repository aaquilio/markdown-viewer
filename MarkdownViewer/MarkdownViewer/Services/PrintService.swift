//
//  PrintService.swift
//  MarkdownViewer
//
//  Handles printing operations for rendered markdown content.
//

import Foundation
import WebKit
import AppKit

class PrintService {
    /// Prints the content of a WKWebView using direct printing (recommended approach)
    /// - Parameters:
    ///   - webView: The WKWebView to print
    ///   - suggestedFilename: Optional filename for PDF export (without extension)
    static func print(webView: WKWebView, suggestedFilename: String? = nil) {
        // Ensure we're on the main thread for UI operations
        DispatchQueue.main.async {
            // Get the window reference - CRITICAL for printing to work
            guard let window = webView.window ?? NSApp.keyWindow ?? NSApp.mainWindow ?? NSApp.windows.first else {
                Swift.print("No window available for printing")
                return
            }

            // Configure print info with sensible defaults
            let printInfo = NSPrintInfo.shared
            printInfo.horizontalPagination = .fit
            printInfo.verticalPagination = .automatic
            printInfo.orientation = .portrait
            printInfo.topMargin = 36      // 0.5 inch
            printInfo.bottomMargin = 36
            printInfo.leftMargin = 36
            printInfo.rightMargin = 36

            // Get print operation from WKWebView - this is the native way
            let printOperation = webView.printOperation(with: printInfo)

            // Set the job title - this becomes the default PDF filename
            if let filename = suggestedFilename {
                printOperation.jobTitle = filename
            }

            // Configure print panel options
            printOperation.showsPrintPanel = true
            printOperation.showsProgressPanel = true
            printOperation.printPanel.options = [
                .showsPaperSize,
                .showsOrientation,
                .showsScaling,
                .showsPrintSelection
            ]

            // CRITICAL: Set the view frame before printing
            // This ensures the WKWebView knows its bounds for rendering
            printOperation.view?.frame = webView.bounds

            // CRITICAL: Use runModal, NOT run() or runOperation()
            // WKWebView requires asynchronous printing operations
            printOperation.runModal(
                for: window,
                delegate: nil,
                didRun: nil,
                contextInfo: nil
            )
        }
    }
}

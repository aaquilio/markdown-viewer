//
//  MarkdownWebView.swift
//  MarkdownViewer
//
//  SwiftUI wrapper for WKWebView to display rendered HTML.
//

import SwiftUI
import WebKit

struct MarkdownWebView: NSViewRepresentable {
    let htmlContent: String
    let onWebViewReady: ((WKWebView) -> Void)?

    init(htmlContent: String, onWebViewReady: ((WKWebView) -> Void)? = nil) {
        self.htmlContent = htmlContent
        self.onWebViewReady = onWebViewReady
    }

    func makeNSView(context: Context) -> PrintableWebView {
        let webView = PrintableWebView()
        webView.wkWebView.setValue(false, forKey: "drawsBackground") // Transparent background
        webView.wkWebView.navigationDelegate = context.coordinator

        // Store reference in coordinator and notify when ready
        context.coordinator.webView = webView.wkWebView
        context.coordinator.onWebViewReady = onWebViewReady

        return webView
    }

    func updateNSView(_ webView: PrintableWebView, context: Context) {
        webView.wkWebView.loadHTMLString(htmlContent, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?
        var onWebViewReady: ((WKWebView) -> Void)?

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject search script after page loads
            SearchService.injectSearchScript(into: webView)

            // Notify that web view is ready
            onWebViewReady?(webView)
        }
    }
}

// Custom NSView wrapper for WKWebView
class PrintableWebView: NSView {
    let wkWebView: WKWebView

    override init(frame frameRect: NSRect) {
        wkWebView = WKWebView(frame: frameRect)
        super.init(frame: frameRect)
        setupWebView()
    }

    required init?(coder: NSCoder) {
        wkWebView = WKWebView(frame: .zero)
        super.init(coder: coder)
        setupWebView()
    }

    private func setupWebView() {
        addSubview(wkWebView)
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wkWebView.topAnchor.constraint(equalTo: topAnchor),
            wkWebView.bottomAnchor.constraint(equalTo: bottomAnchor),
            wkWebView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wkWebView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

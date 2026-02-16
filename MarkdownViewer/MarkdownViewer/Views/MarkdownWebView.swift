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

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard navigationAction.navigationType == .linkActivated,
                  let url = navigationAction.request.url
            else {
                decisionHandler(.allow)
                return
            }

            // Anchor link within the document.
            // Down percent-encodes '#' in hrefs, so the URL may arrive as
            // about:blank%23fragment (no real URL fragment) rather than about:blank#fragment.
            if url.scheme == "about" {
                let fragment = url.fragment
                    ?? url.absoluteString.components(separatedBy: "%23").dropFirst().joined(separator: "%23")
                if !fragment.isEmpty {
                    let safe = fragment.replacingOccurrences(of: "'", with: "\\'")
                    let js = "document.getElementById('\(safe)')?.scrollIntoView({behavior:'smooth'});"
                    webView.evaluateJavaScript(js, completionHandler: nil)
                }
                decisionHandler(.cancel)
                return
            }

            // External link — open in system browser
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
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

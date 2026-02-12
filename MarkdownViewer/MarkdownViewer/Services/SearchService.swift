//
//  SearchService.swift
//  MarkdownViewer
//
//  Service for searching and highlighting text in WebView.
//

import Foundation
import WebKit

class SearchService {
    /// JavaScript code for search functionality
    private static let searchScript = """
    (function() {
        window.MarkdownSearch = {
            currentIndex: 0,
            matches: [],

            // Clear all highlights
            clear: function() {
                const highlights = document.querySelectorAll('.md-search-highlight');
                highlights.forEach(el => {
                    const parent = el.parentNode;
                    parent.replaceChild(document.createTextNode(el.textContent), el);
                    parent.normalize();
                });
                this.matches = [];
                this.currentIndex = 0;
            },

            // Search for text and highlight all occurrences
            search: function(searchText) {
                this.clear();

                if (!searchText || searchText.trim() === '') {
                    return { currentIndex: 0, totalMatches: 0 };
                }

                const bodyText = document.body.innerHTML;
                const searchRegex = new RegExp(searchText.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&'), 'gi');

                // Find all text nodes
                const walker = document.createTreeWalker(
                    document.body,
                    NodeFilter.SHOW_TEXT,
                    null,
                    false
                );

                const nodesToProcess = [];
                let node;
                while (node = walker.nextNode()) {
                    if (node.nodeValue && node.nodeValue.match(searchRegex)) {
                        nodesToProcess.push(node);
                    }
                }

                // Highlight matches
                nodesToProcess.forEach(textNode => {
                    const parent = textNode.parentNode;
                    if (parent.nodeName === 'SCRIPT' || parent.nodeName === 'STYLE') {
                        return;
                    }

                    const text = textNode.nodeValue;
                    const fragment = document.createDocumentFragment();
                    let lastIndex = 0;
                    let match;
                    const regex = new RegExp(searchText.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&'), 'gi');

                    while ((match = regex.exec(text)) !== null) {
                        // Add text before match
                        if (match.index > lastIndex) {
                            fragment.appendChild(document.createTextNode(text.substring(lastIndex, match.index)));
                        }

                        // Add highlighted match
                        const span = document.createElement('span');
                        span.className = 'md-search-highlight';
                        span.textContent = match[0];
                        fragment.appendChild(span);
                        this.matches.push(span);

                        lastIndex = regex.lastIndex;
                    }

                    // Add remaining text
                    if (lastIndex < text.length) {
                        fragment.appendChild(document.createTextNode(text.substring(lastIndex)));
                    }

                    parent.replaceChild(fragment, textNode);
                });

                // Highlight first match
                if (this.matches.length > 0) {
                    this.currentIndex = 0;
                    this.highlightCurrent();
                }

                return { currentIndex: this.matches.length > 0 ? 1 : 0, totalMatches: this.matches.length };
            },

            // Highlight current match and scroll to it
            highlightCurrent: function() {
                // Remove current highlight from all
                this.matches.forEach(el => el.classList.remove('md-search-current'));

                if (this.matches.length > 0) {
                    const current = this.matches[this.currentIndex];
                    current.classList.add('md-search-current');
                    current.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            },

            // Go to next match
            next: function() {
                if (this.matches.length === 0) return { currentIndex: 0, totalMatches: 0 };

                this.currentIndex = (this.currentIndex + 1) % this.matches.length;
                this.highlightCurrent();

                return { currentIndex: this.currentIndex + 1, totalMatches: this.matches.length };
            },

            // Go to previous match
            previous: function() {
                if (this.matches.length === 0) return { currentIndex: 0, totalMatches: 0 };

                this.currentIndex = (this.currentIndex - 1 + this.matches.length) % this.matches.length;
                this.highlightCurrent();

                return { currentIndex: this.currentIndex + 1, totalMatches: this.matches.length };
            }
        };

        // Add CSS for highlights
        const style = document.createElement('style');
        style.textContent = `
            .md-search-highlight {
                background-color: rgba(255, 255, 0, 0.4);
                border-radius: 2px;
            }
            .md-search-current {
                background-color: rgba(255, 165, 0, 0.6);
                outline: 2px solid rgba(255, 140, 0, 0.8);
                outline-offset: 1px;
            }
        `;
        document.head.appendChild(style);
    })();
    """

    /// Injects search script into WebView
    static func injectSearchScript(into webView: WKWebView) {
        webView.evaluateJavaScript(searchScript) { _, error in
            if let error = error {
                print("Failed to inject search script: \(error)")
            }
        }
    }

    /// Searches for text in WebView
    static func search(in webView: WKWebView, text: String, completion: @escaping (Int, Int) -> Void) {
        let escapedText = text.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")

        let script = "window.MarkdownSearch.search('\(escapedText)')"

        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("Search error: \(error)")
                completion(0, 0)
                return
            }

            if let dict = result as? [String: Int],
               let currentIndex = dict["currentIndex"],
               let totalMatches = dict["totalMatches"] {
                completion(currentIndex, totalMatches)
            } else {
                completion(0, 0)
            }
        }
    }

    /// Finds next occurrence
    static func findNext(in webView: WKWebView, completion: @escaping (Int, Int) -> Void) {
        webView.evaluateJavaScript("window.MarkdownSearch.next()") { result, error in
            if let error = error {
                print("Find next error: \(error)")
                completion(0, 0)
                return
            }

            if let dict = result as? [String: Int],
               let currentIndex = dict["currentIndex"],
               let totalMatches = dict["totalMatches"] {
                completion(currentIndex, totalMatches)
            } else {
                completion(0, 0)
            }
        }
    }

    /// Finds previous occurrence
    static func findPrevious(in webView: WKWebView, completion: @escaping (Int, Int) -> Void) {
        webView.evaluateJavaScript("window.MarkdownSearch.previous()") { result, error in
            if let error = error {
                print("Find previous error: \(error)")
                completion(0, 0)
                return
            }

            if let dict = result as? [String: Int],
               let currentIndex = dict["currentIndex"],
               let totalMatches = dict["totalMatches"] {
                completion(currentIndex, totalMatches)
            } else {
                completion(0, 0)
            }
        }
    }

    /// Clears all search highlights
    static func clearSearch(in webView: WKWebView) {
        webView.evaluateJavaScript("window.MarkdownSearch.clear()") { _, error in
            if let error = error {
                print("Clear search error: \(error)")
            }
        }
    }
}

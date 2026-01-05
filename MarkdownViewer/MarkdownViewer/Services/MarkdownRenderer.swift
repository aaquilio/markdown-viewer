//
//  MarkdownRenderer.swift
//  MarkdownViewer
//
//  Service for converting markdown to styled HTML.
//

import Foundation
import Down

class MarkdownRenderer {
    /// Converts markdown text to HTML with syntax highlighting
    static func render(markdown: String) throws -> String {
        let down = Down(markdownString: markdown)

        // Convert markdown to HTML
        let html = try down.toHTML()

        // Wrap in a styled HTML document
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">

            <!-- Highlight.js CSS for syntax highlighting -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css" media="(prefers-color-scheme: light)">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css" media="(prefers-color-scheme: dark)">

            <style>
                :root {
                    --text-color: #1d1d1f;
                    --bg-color: #ffffff;
                    --code-bg: #f5f5f7;
                    --border-color: #d2d2d7;
                    --link-color: #0066cc;
                }

                @media (prefers-color-scheme: dark) {
                    :root {
                        --text-color: #f5f5f7;
                        --bg-color: #1d1d1f;
                        --code-bg: #2d2d2d;
                        --border-color: #424245;
                        --link-color: #2997ff;
                    }
                }

                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    color: var(--text-color);
                    background-color: var(--bg-color);
                    max-width: 900px;
                    margin: 0 auto;
                    padding: 20px;
                }

                h1, h2, h3, h4, h5, h6 {
                    margin-top: 24px;
                    margin-bottom: 16px;
                    font-weight: 600;
                    line-height: 1.25;
                }

                h1 {
                    font-size: 2em;
                    border-bottom: 1px solid var(--border-color);
                    padding-bottom: 0.3em;
                }

                h2 {
                    font-size: 1.5em;
                    border-bottom: 1px solid var(--border-color);
                    padding-bottom: 0.3em;
                }

                h3 { font-size: 1.25em; }
                h4 { font-size: 1em; }
                h5 { font-size: 0.875em; }
                h6 { font-size: 0.85em; color: #6a737d; }

                p {
                    margin-top: 0;
                    margin-bottom: 16px;
                }

                a {
                    color: var(--link-color);
                    text-decoration: none;
                }

                a:hover {
                    text-decoration: underline;
                }

                code {
                    font-family: "SF Mono", Monaco, "Courier New", monospace;
                    font-size: 0.9em;
                    padding: 0.2em 0.4em;
                    background-color: var(--code-bg);
                    border-radius: 3px;
                }

                pre {
                    font-family: "SF Mono", Monaco, "Courier New", monospace;
                    font-size: 0.9em;
                    padding: 16px;
                    overflow: auto;
                    border-radius: 6px;
                    line-height: 1.45;
                }

                /* Remove background for code inside pre (Highlight.js handles it) */
                pre code {
                    padding: 0;
                    background-color: transparent !important;
                    border-radius: 0;
                }

                blockquote {
                    margin: 0;
                    padding: 0 1em;
                    color: #6a737d;
                    border-left: 0.25em solid var(--border-color);
                }

                table {
                    border-spacing: 0;
                    border-collapse: collapse;
                    width: 100%;
                    margin-bottom: 16px;
                }

                table th,
                table td {
                    padding: 6px 13px;
                    border: 1px solid var(--border-color);
                }

                table th {
                    font-weight: 600;
                    background-color: var(--code-bg);
                }

                table tr:nth-child(2n) {
                    background-color: var(--code-bg);
                    opacity: 0.5;
                }

                ul, ol {
                    margin-top: 0;
                    margin-bottom: 16px;
                    padding-left: 2em;
                }

                li + li {
                    margin-top: 0.25em;
                }

                hr {
                    height: 0.25em;
                    padding: 0;
                    margin: 24px 0;
                    background-color: var(--border-color);
                    border: 0;
                }

                img {
                    max-width: 100%;
                    box-sizing: content-box;
                }
            </style>
        </head>
        <body>
            \(html)

            <!-- Highlight.js library and initialization -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
            <script>
                // Automatically highlight all code blocks
                document.addEventListener('DOMContentLoaded', function() {
                    hljs.highlightAll();
                });
            </script>
        </body>
        </html>
        """
    }
}

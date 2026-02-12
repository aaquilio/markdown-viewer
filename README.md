# Markdown Viewer

A native macOS application for viewing and browsing Markdown files with live reload and syntax highlighting.

## Features

- **Three-Pane Layout**: Directory selector, hierarchical file tree, and markdown preview
- **Live Markdown Rendering**: Instant preview of markdown files using the Down library (cmark-based)
- **Syntax Highlighting**: Code blocks highlighted with Highlight.js
- **Live File Watching**: Automatically reloads when files change externally
- **Print & PDF Export**: Print documents or save as PDF with automatic filename matching (Cmd+P)
- **Collapsible Sidebar**: Hide/show directory selector to maximize viewing space
- **GitHub-Flavored Styling**: Familiar markdown rendering with tables, code blocks, and more
- **Dark Mode Support**: Automatically adapts to system appearance

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later (for building from source)

## Installation

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/aaquilio/markdown-viewer.git
   cd markdown-viewer
   ```

2. **Option A: Command Line Build (Recommended)**
   ```bash
   # Debug build
   ./build.sh --debug

   # Release build (default)
   ./build.sh --release

   # Clean build
   ./build.sh --clean --release

   # Run the app
   open "build/Markdown Viewer.app"
   ```

3. **Option B: Build in Xcode**
   ```bash
   open MarkdownViewer/MarkdownViewer.xcodeproj
   ```
   - Select the `MarkdownViewer` scheme
   - Press `Cmd+R` to build and run

## Usage

1. **Launch the app** and click "Select Directory"
2. **Choose a folder** containing markdown files
3. **Browse files** in the file tree (middle pane)
4. **Click any .md file** to view its rendered content
5. **Toggle the directory selector** using the sidebar button in the file tree toolbar

### Supported File Types

The viewer automatically filters and displays:
- `.md` files
- `.markdown` files

## Architecture

Built with modern Swift and SwiftUI:

- **SwiftUI**: Declarative UI with `NavigationSplitView` for three-pane layout
- **@Observable Macro**: Modern state management (Swift 5.9+)
- **Down Library**: High-performance markdown parsing using libcmark
- **Highlight.js**: Client-side syntax highlighting for code blocks
- **DispatchSource**: File system monitoring for live reload
- **App Sandbox**: Sandboxed with user-selected file access

### Project Structure

```
MarkdownViewer/
├── MarkdownViewer/
│   ├── Models/
│   │   ├── AppState.swift          # Central app state management
│   │   └── FileItem.swift          # File tree data model
│   ├── Views/
│   │   ├── ContentView.swift       # Main three-pane layout
│   │   ├── FilePickerView.swift    # Directory selector sidebar
│   │   ├── FileTreeView.swift      # File tree browser
│   │   ├── MarkdownContentView.swift # Content display wrapper
│   │   └── MarkdownWebView.swift   # WKWebView wrapper
│   ├── Services/
│   │   ├── MarkdownRenderer.swift  # Markdown to HTML conversion
│   │   ├── FileWatcher.swift       # File system monitoring
│   │   └── PrintService.swift      # Print and PDF export
│   └── Resources/
│       └── Assets.xcassets/        # App icons and assets
```

## Development

This project follows conventional commit standards and uses feature branches:

### Git Workflow

- `main` - Production-ready code
- `feature/*` - Feature development branches
- `bugfix/*` - Bug fix branches

### Commit Message Format

Following [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <description>

[optional body]
```

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`

## Dependencies

- [Down](https://github.com/johnxnguyen/Down) - High-performance markdown parser
- [Highlight.js](https://highlightjs.org/) - Syntax highlighting (loaded from CDN)

## Roadmap

Future enhancements planned:
- Custom CSS themes
- Table of contents generation
- Search functionality
- Bookmark management
- Export to HTML

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes using conventional commits
4. Push to your branch
5. Open a Pull Request

## License

This project is open source. License to be determined.

## Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Markdown parsing by [Down](https://github.com/johnxnguyen/Down)
- Syntax highlighting by [Highlight.js](https://highlightjs.org/)
- Developed with assistance from [Claude Code](https://claude.com/claude-code)

---

**Note**: This is a native macOS application and requires macOS 14.0 or later.

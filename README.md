# FileManagerKit

A small base for a "My Files" screen: list, sort, multi-select, and file
operations (create folder, save, rename, move, copy, duplicate, delete) with
Files-app-style collision naming — behind a testable port.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/iOS-17%2B-blue.svg)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

## Features

- **`FileItem`** — file/folder metadata (kind, size, dates, display name, SF Symbol).
- **`FileStore`** — the operations port; **`DocumentFileStore`** implements it over
  `FileManager` with auto-increment naming (`"note (1)"`) on collision.
- **`FilesModel`** — an `@Observable` view model: sorting (folders first), multi-select,
  navigation into folders, and all operations forwarded to the port.
- **`FileThumbnail`** — QuickLook thumbnails for any file type.

## Installation

```swift
.package(url: "https://github.com/theanvora/FileManagerKit.git", from: "1.0.0")
```

## Usage

```swift
import FileManagerKit

@State private var files = FilesModel(store: DocumentFileStore())

// List
ForEach(files.items) { item in
    Label(item.displayName, systemImage: item.kind.systemImageName)
}

// Operations
files.createFolder(named: "Invoices")
files.rename(item, to: "March")
files.duplicate(item)
files.deleteSelected()

// Thumbnail
let image = await FileThumbnail.generate(for: item.url, size: CGSize(width: 80, height: 100))
```

Inject a temp-directory `DocumentFileStore(root:)` in tests — no real Documents folder needed.

## Requirements

- iOS 17.0+ · Swift 5.9+

## License

MIT

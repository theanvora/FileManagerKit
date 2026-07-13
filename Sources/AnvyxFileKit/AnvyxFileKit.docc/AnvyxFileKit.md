# ``AnvyxFileKit``

A "My Files" toolkit: a file-store abstraction, a ready-made files view model,
thumbnails, security-scoped bookmarks, iCloud, change monitoring, favorites,
search, and undoable operations.

## Overview

Depend on the ``FileStore`` port (backed by ``DocumentFileStore``, or a temp dir
in tests) and drive UI with ``FilesModel``. Add cross-cutting capabilities —
bookmarks, iCloud, favorites, undo — as needed.

```swift
let store = DocumentFileStore()
let files = FilesModel(store: store)       // sort/search/CRUD/clipboard/multi-select
for await _ in DirectoryMonitor.changes(of: folder) { await files.reload() }
```

## Topics

### Store & Model
- ``FileStore``
- ``DocumentFileStore``
- ``FilesModel``
- ``FileItem``
- ``FileKind``
- ``FileClipboard``
- ``FileThumbnail``

### Access & Sync
- ``FileBookmark``
- ``UbiquityContainer``
- ``DirectoryMonitor``

### Organize
- ``FileFavorites``
- ``FavoritesStore``
- ``FileSearchIndex``
- ``FileUndoManager``

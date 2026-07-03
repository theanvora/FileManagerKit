//
//  DocumentFileStore.swift
//  FileManagerKit
//
//  Created by AnhPT on 04/07/2026.
//

import Foundation

/// `FileStore` backed by `FileManager`, rooted at a directory (Documents by
/// default). Collision handling appends " (1)", " (2)", … like the Files app.
public struct DocumentFileStore: FileStore {
    public let root: URL
    private var fileManager: FileManager { .default }

    public init(root: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]) {
        self.root = root
    }

    public func contents(of directory: URL) throws -> [FileItem] {
        let urls = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        return urls.map(FileItem.init(url:))
    }

    public func search(_ query: String, in directory: URL) throws -> [FileItem] {
        guard !query.isEmpty,
              let enumerator = fileManager.enumerator(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey],
                options: [.skipsHiddenFiles]
              )
        else { return [] }

        var results: [FileItem] = []
        for case let url as URL in enumerator where url.lastPathComponent.localizedCaseInsensitiveContains(query) {
            results.append(FileItem(url: url))
        }
        return results
    }

    @discardableResult
    public func createFolder(named name: String, in directory: URL) throws -> FileItem {
        let url = uniqueURL(baseName: name, extension: nil, in: directory)
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        return FileItem(url: url)
    }

    @discardableResult
    public func save(_ data: Data, name: String, in directory: URL) throws -> FileItem {
        let base = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension
        let url = uniqueURL(baseName: base, extension: ext.isEmpty ? nil : ext, in: directory)
        try data.write(to: url, options: .atomic)
        return FileItem(url: url)
    }

    @discardableResult
    public func rename(_ item: FileItem, to newName: String) throws -> FileItem {
        let directory = item.url.deletingLastPathComponent()
        var destination = directory.appendingPathComponent(newName)
        if !item.isDirectory, !item.url.pathExtension.isEmpty {
            destination = destination.appendingPathExtension(item.url.pathExtension)
        }
        guard destination != item.url else { return item }
        guard !fileManager.fileExists(atPath: destination.path) else { throw FileStoreError.nameAlreadyExists }
        try fileManager.moveItem(at: item.url, to: destination)
        return FileItem(url: destination)
    }

    @discardableResult
    public func move(_ item: FileItem, to directory: URL) throws -> FileItem {
        let destination = uniqueURL(for: item, in: directory)
        try fileManager.moveItem(at: item.url, to: destination)
        return FileItem(url: destination)
    }

    @discardableResult
    public func copy(_ item: FileItem, to directory: URL) throws -> FileItem {
        let destination = uniqueURL(for: item, in: directory)
        try fileManager.copyItem(at: item.url, to: destination)
        return FileItem(url: destination)
    }

    @discardableResult
    public func duplicate(_ item: FileItem) throws -> FileItem {
        try copy(item, to: item.url.deletingLastPathComponent())
    }

    public func delete(_ item: FileItem) throws {
        try fileManager.removeItem(at: item.url)
    }

    // MARK: - Collision-safe naming

    private func uniqueURL(for item: FileItem, in directory: URL) -> URL {
        let base = item.isDirectory ? item.name : item.url.deletingPathExtension().lastPathComponent
        let ext = item.isDirectory ? nil : (item.url.pathExtension.isEmpty ? nil : item.url.pathExtension)
        return uniqueURL(baseName: base, extension: ext, in: directory)
    }

    private func uniqueURL(baseName: String, extension ext: String?, in directory: URL) -> URL {
        func make(_ name: String) -> URL {
            let url = directory.appendingPathComponent(name)
            return ext.map { url.appendingPathExtension($0) } ?? url
        }
        var candidate = make(baseName)
        var counter = 1
        while fileManager.fileExists(atPath: candidate.path) {
            candidate = make("\(baseName) (\(counter))")
            counter += 1
        }
        return candidate
    }
}

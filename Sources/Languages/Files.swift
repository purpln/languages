//
//  File.swift
//  
//
//  Created by Sergey Romanenko on 01.10.2021.
//

import Foundation

class Files {
    static var manager: FileManager { .default }
    static var directory: URL { manager.urls(for: .documentDirectory, in: .userDomainMask).first! }
    
    static func rewrite(_ path: String, _ data: Data?) -> Bool {
        guard let data = data else { return false }
        if exists(path) {
            if remove(path) {
                guard let _ = try? data.write(to: url(path)) else { return false }
            } else { return false }
        } else {
            guard let _ = try? data.write(to: url(path)) else { return false }
        }
        return true
    }
    static func remove(_ path: String) -> Bool {
        if path != "" {
            guard let _ = try? manager.removeItem(at: url(path)) else { return true }
        } else {
            guard let files = files() else { return false }
            for file in files {
                let path = directory.appendingPathComponent(file)
                guard let _ = try? manager.removeItem(at: path) else { continue }
            }
        }
        return true
    }
    static func exists(_ file: String) -> Bool {
        manager.fileExists(atPath: url(file).path)
    }
    static func files(_ folder: String = "") -> Array<String>? {
        try? manager.contentsOfDirectory(atPath: url(folder).path)
    }
    static func folder(_ folder: String) -> Bool {
        guard !exists(folder) else { return false }
        guard let _ = try? manager.createDirectory(atPath: url(folder).path, withIntermediateDirectories: true) else { return true }
        return false
    }
    static func url(_ path: String) -> URL {
        directory.appendingPathComponent(path)
    }
}

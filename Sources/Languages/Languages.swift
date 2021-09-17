import Foundation

public class Languages {
    static var shared: Languages = Languages()
    
    public static func localize(key: String, language: String) -> String {
        guard let dictionary = Languages.shared.read(language)?.dict,
              let string = dictionary[key] as? String else { return key }
        return string
    }
    
    private func read(_ language: String) -> Data? {
        let path = directory.appendingPathComponent("localization/" + language + ".json")
        return try? Data(contentsOf: path)
    }
    
    public var languages: [String]? {
        guard let languages = files("localization") else { return nil }
        return languages.map { $0.replacingOccurrences(of: ".json", with: "")}
    }
    
    private var update: [String] {
        var updated: [String] = []
        for language in available {
            guard let path = Bundle.main.path(forResource: language, ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let _ = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  rewrite("localization/" + language + ".json", data) else { continue }
            updated.append(language)
        }
        return updated
    }
    
    init() {
        if languages == nil { _ = folder("localization") }
        print("log: app langugaes updated:", update.joined(separator: ", "))
    }
    
    var available: [String] = ["en", "ru"]
}

private extension Languages {
    var manager: FileManager { .default }
    var directory: URL { manager.urls(for: .documentDirectory, in: .userDomainMask).first! }
    
    func rewrite(_ path: String, _ data: Data?) -> Bool {
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
    func remove(_ path: String) -> Bool {
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
    func exists(_ file: String) -> Bool {
        manager.fileExists(atPath: url(file).path)
    }
    func files(_ folder: String = "") -> Array<String>? {
        try? manager.contentsOfDirectory(atPath: url(folder).path)
    }
    func folder(_ folder: String) -> Bool {
        guard !exists(folder) else { return false }
        guard let _ = try? manager.createDirectory(atPath: url(folder).path, withIntermediateDirectories: true) else { return true }
        return false
    }
    func url(_ path: String) -> URL {
        directory.appendingPathComponent(path)
    }
}

private extension Data {
    var dict: [String: Any]? { try? JSONSerialization.jsonObject(with: self) as? [String: Any] }
}

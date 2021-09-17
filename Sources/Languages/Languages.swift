import Foundation

public class Languages {
    static var shared: Languages = Languages()
    
    public static func localize(key: String, language: String) -> String {
        guard let dictionary = Languages.shared.read(language)?.dict,
              let string = dictionary[key] as? String else { return key }
        return string
    }
    
    public var languages: [String]? {
        guard let languages = files("languages") else { return nil }
        return languages.map { $0.replacingOccurrences(of: ".json", with: "")}
    }
    
    private func read(_ language: String) -> Data? {
        let path = directory.appendingPathComponent("languages/" + language + ".json")
        return try? Data(contentsOf: path)
    }
    
    private var update: String {
        var updated: [String] = []
        let languages: [String] = ["en", "ru"]
        for language in languages {
            guard let path = Bundle.main.path(forResource: language, ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)), let _ = data.dict,
                  rewrite("languages/" + language + ".json", data) else { continue }
            updated.append(language)
        }
        return "updated languages: " + updated.joined(separator: ", ")
    }
    
    init() {
        if languages == nil { guard folder("languages") else { return } }
        print(update)
    }
}

extension Languages {
    private var manager: FileManager { .default }
    public var directory: URL { manager.urls(for: .documentDirectory, in: .userDomainMask).first! }
    
    private func rewrite(_ path: String, _ data: Data?) -> Bool {
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
    private func remove(_ path: String) -> Bool {
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
    private func exists(_ file: String) -> Bool {
        manager.fileExists(atPath: url(file).path)
    }
    private func files(_ folder: String = "") -> Array<String>? {
        try? manager.contentsOfDirectory(atPath: url(folder).path)
    }
    private func folder(_ folder: String) -> Bool {
        guard !exists(folder) else { return false }
        guard let _ = try? manager.createDirectory(atPath: url(folder).path, withIntermediateDirectories: true) else { return true }
        return false
    }
    private func url(_ path: String) -> URL {
        directory.appendingPathComponent(path)
    }
}

private extension Data {
    var dict: [String: Any]? { try? JSONSerialization.jsonObject(with: self) as? [String: Any] }
}

import Foundation

public class Languages {
    public static var shared: Languages = Languages()
    
    public static var dictionary: [String: String] = [:]
    
    public func localize(key: String) -> String {
        guard let string = Self.dictionary[key] else { return key }
        return string
    }
    
    private func read(_ language: String) -> Data? {
        let path = directory.appendingPathComponent("localization/" + language + ".json")
        return try? Data(contentsOf: path)
    }
    
    private var languages: [String]? {
        guard let languages = files("localization") else { return nil }
        return languages.map { $0.replacingOccurrences(of: ".json", with: "")}
    }
    
    @discardableResult
    public static func update() -> [String] {
        var updated: [String] = []
        print(available)
        for language in available {
            guard let path = Bundle.main.path(forResource: language, ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let _ = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  shared.rewrite("localization/" + language + ".json", data) else { continue }
            updated.append(language)
        }
        return updated
    }
    
    init() {
        if languages == nil { guard folder("localization") else { fatalError() } }
        if languages?.count == 0 { let languages = Languages.update();
            print("languages (\(languages.joined(separator: ", "))) created") }
        print("available languages: ", languages?.joined(separator: ", ") ?? "nil")
        print(Self.current, read(Self.current)?.dict)
        guard let dictionary = read(Self.current)?.dict as? [String: String] else { fatalError() }
        Languages.dictionary = dictionary
    }
    
    public static var languages: [String]? { shared.languages }
    public static var available: [String] { ["en", "ru"] }
    public static var current: String {
        guard let language = Bundle.main.preferredLocalizations.first,
              let languages = languages,
              languages.contains(language) else { return "en" }
        return language
    }
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

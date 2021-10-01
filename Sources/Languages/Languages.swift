import Foundation

public class Languages {
    public static var shared: Languages? = Languages()
    
    public var dictionary: [String: String] = [:]
    
    public func localize(key: String) -> String {
        guard let string = dictionary[key] else { return key }
        return string
    }
    
    public var languages: [String]? {
        guard let languages = Files.files("localization") else { return nil }
        return languages.map { $0.replacingOccurrences(of: ".json", with: "")}
    }
    
    private var data: Data? {
        let path = Files.directory.appendingPathComponent("localization/" + current + ".json")
        return try? Data(contentsOf: path)
    }
    
    @discardableResult
    public func update() -> [String] {
        var updated: [String] = []
        for language in available {
            guard let path = Bundle.main.path(forResource: language, ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let _ = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  Files.rewrite("localization/" + language + ".json", data) else { continue }
            updated.append(language)
        }
        return updated
    }
    
    init?() {
        if languages == nil { guard Files.folder("localization") else { return nil } }
        if languages?.count == 0 { update() }
        guard let dictionary = data?.dict else { return nil }
        self.dictionary = dictionary
    }
    
    public var available: [String] { ["en", "ru"] }
    public var current: String {
        guard let language = Bundle.main.preferredLocalizations.first,
              let languages = languages,
              languages.contains(language) else { return "en" }
        return language
    }
}

private extension Data {
    var dict: [String: String]? { try? JSONSerialization.jsonObject(with: self) as? [String: String] }
}

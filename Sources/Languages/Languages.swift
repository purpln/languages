import Foundation

public class Languages {
    public static var shared: Languages? = Languages()
    
    public static var dictionary: [String: String] = [:]
    
    public func localize(key: String) -> String {
        guard let string = Self.dictionary[key] else { return key }
        return string
    }
    
    private func read(_ language: String) -> Data? {
        let path = Files.directory.appendingPathComponent("localization/" + language + ".json")
        return try? Data(contentsOf: path)
    }
    
    private var languages: [String]? {
        guard let languages = Files.files("localization") else { return nil }
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
                  Files.rewrite("localization/" + language + ".json", data) else { continue }
            updated.append(language)
        }
        return updated
    }
    
    init?() {
        if languages == nil { guard Files.folder("localization") else { return nil } }
        if languages?.count == 0 { let languages = Languages.update();
            print("languages (\(languages.joined(separator: ", "))) created") }
        print("available languages: ", languages?.joined(separator: ", ") ?? "nil")
        print(Self.current, read(Self.current)?.dict)
        //guard let dictionary = read(Self.current)?.dict as? [String: String] else { fatalError() }
        //Languages.dictionary = dictionary
    }
    
    public static var languages: [String]? { shared?.languages }
    public static var available: [String] { ["en", "ru"] }
    public static var current: String {
        guard let language = Bundle.main.preferredLocalizations.first,
              let languages = languages,
              languages.contains(language) else { return "en" }
        return language
    }
}

private extension Data {
    var dict: [String: Any]? { try? JSONSerialization.jsonObject(with: self) as? [String: Any] }
}

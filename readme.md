```swift
Languages.shared?.changed("en")
UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
print(Languages.shared?.current ?? "nil", Languages.shared?.dictionary ?? "nil")
```

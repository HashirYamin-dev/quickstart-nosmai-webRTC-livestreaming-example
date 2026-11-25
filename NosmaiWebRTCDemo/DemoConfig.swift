import Foundation

/// All the settings this demo needs. Replace the values below with your own.
///
/// - Nosmai API key: from your Nosmai dashboard. It is tied to the app's bundle
///   identifier, so the bundle ID in Xcode must match the one registered for the key.
/// - Room name: any name. The host and the audience must use the same one.
///
/// WebRTC itself needs no keys. This demo finds the other phone over the local
/// network (see LocalSignaling.swift), so both phones must be on the same Wi-Fi.
struct DemoConfig {
    static let nosmaiAPIKey = "YOUR_NOSMAI_API_KEY"
    static let roomName = "demo-room"

    let nosmaiAPIKey: String
    let roomName: String

    /// Returns the config, or a human readable reason when a value is still missing.
    static func load() -> Result<DemoConfig, ConfigError> {
        func clean(_ value: String) -> String { value.trimmingCharacters(in: .whitespacesAndNewlines) }
        let config = DemoConfig(nosmaiAPIKey: clean(nosmaiAPIKey), roomName: clean(roomName))
        if config.nosmaiAPIKey.isEmpty || config.nosmaiAPIKey.hasPrefix("YOUR_") {
            return .failure(.init(message: "Set nosmaiAPIKey in DemoConfig.swift."))
        }
        if config.roomName.isEmpty { return .failure(.init(message: "Set roomName in DemoConfig.swift.")) }
        return .success(config)
    }

    struct ConfigError: Error { let message: String }
}

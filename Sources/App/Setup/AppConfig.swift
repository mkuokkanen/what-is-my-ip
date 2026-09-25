import Vapor

/// Application settings, read from environment variables at startup.
struct AppConfig {
  /// Where to read the client IP from (IP_SOURCE). Defaults to the connecting address.
  var ipSource: IpSource
  /// Log all request headers at debug level (LOG_HEADERS=true). For debugging only.
  var logHeaders: Bool

  /// Reads the settings from environment variables. Throws if a value is invalid.
  /// `get` looks up a variable by name; tests pass their own values instead of the process's.
  static func fromEnvironment(_ get: (String) -> String? = Environment.get) throws -> AppConfig {
    AppConfig(
      ipSource: try IpSource.parse(get("IP_SOURCE")) ?? .remoteAddress,
      logHeaders: get("LOG_HEADERS").flatMap(Bool.init) ?? false
    )
  }
}

extension AppConfig: CustomStringConvertible {
  /// Settings with their environment variable names, for logging at startup.
  var description: String {
    "IP_SOURCE=\(ipSource.rawValue), LOG_HEADERS=\(logHeaders)"
  }
}

extension Application {
  /// Key for storing AppConfig in the application's storage
  private struct AppConfigKey: StorageKey {
    typealias Value = AppConfig
  }

  /// Application settings, set once at startup in configure()
  var appConfig: AppConfig {
    get {
      guard let config = storage[AppConfigKey.self] else {
        fatalError("app.appConfig is not set; configure() must set it first")
      }
      return config
    }
    set { storage[AppConfigKey.self] = newValue }
  }
}

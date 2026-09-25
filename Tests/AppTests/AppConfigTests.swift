import Testing

@testable import App

/// Reading settings from environment variables.
@Suite("App Config Tests")
struct AppConfigTests {

  /// Reads the config from the given variables instead of the process environment.
  private func config(_ variables: [String: String]) throws -> AppConfig {
    try AppConfig.fromEnvironment { variables[$0] }
  }

  @Test("No variables gives the defaults")
  func defaults() throws {
    let config = try config([:])
    #expect(config.ipSource == .remoteAddress)
    #expect(config.logHeaders == false)
  }

  @Test("IP_SOURCE is read")
  func ipSource() throws {
    #expect(try config(["IP_SOURCE": "x-forwarded-for"]).ipSource == .xForwardedFor)
  }

  @Test("Invalid IP_SOURCE throws")
  func invalidIpSource() {
    #expect(throws: InvalidIpSource.self) {
      try config(["IP_SOURCE": "bogus"])
    }
  }

  @Test(
    "LOG_HEADERS is true only for 'true'",
    arguments: [("true", true), ("false", false), ("1", false), ("yes", false), ("", false)])
  func logHeaders(value: String, expected: Bool) throws {
    #expect(try config(["LOG_HEADERS": value]).logHeaders == expected)
  }
}

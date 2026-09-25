import Testing

@testable import App

/// Parsing IP_SOURCE values.
@Suite("IP Source Tests")
struct IpSourceTests {

  @Test("Missing value returns nil")
  func parseMissing() throws {
    #expect(try IpSource.parse(nil) == nil)
  }

  @Test("Valid values are parsed", arguments: IpSource.allCases)
  func parseValid(source: IpSource) throws {
    #expect(try IpSource.parse(source.rawValue) == source)
  }

  @Test("Invalid values throw", arguments: ["", "X-Forwarded-For", "remote", "xff"])
  func parseInvalid(value: String) {
    #expect(throws: InvalidIpSource.self) {
      try IpSource.parse(value)
    }
  }
}

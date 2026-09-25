import Testing
import VaporTesting

@testable import App

/// Reading the client IP from requests, in each IP_SOURCE mode.
@Suite("IP Request Tests")
struct IpRequestTests {

  @Test("x-forwarded-for: missing header returns 400")
  func xForwardedForMissingHeader() async throws {
    try await withApp(ipSource: .xForwardedFor) { app in
      try await app.testing().test(
        .GET, "/",
        afterResponse: { res async in
          #expect(res.status == .badRequest)
          #expect(res.body.string == "No IP in headers")
        })
    }
  }

  @Test("x-forwarded-for: single IP returns 200 with the IP")
  func xForwardedForSingleIp() async throws {
    try await withApp(ipSource: .xForwardedFor) { app in
      try await app.testing().test(
        .GET, "/",
        headers: [
          "X-Forwarded-For": "127.0.0.1"
        ],
        afterResponse: { res async in
          #expect(res.status == .ok)
          #expect(res.body.string == "127.0.0.1")
        })
    }
  }

  @Test(
    "x-forwarded-for: multiple IPs return 200 with the first IP",
    arguments: [
      "203.0.113.195,2001:db8:85a3:8d3:1319:8a2e:370:7348,198.51.100.178",
      " 203.0.113.195 , 198.51.100.178",
    ])
  func xForwardedForMultipleIps(header: String) async throws {
    try await withApp(ipSource: .xForwardedFor) { app in
      try await app.testing().test(
        .GET, "/",
        headers: [
          "X-Forwarded-For": header
        ],
        afterResponse: { res async in
          #expect(res.status == .ok)
          #expect(res.body.string == "203.0.113.195")
        })
    }
  }

  @Test("x-forwarded-for: Forwarded header is ignored")
  func xForwardedForIgnoresForwarded() async throws {
    try await withApp(ipSource: .xForwardedFor) { app in
      try await app.testing().test(
        .GET, "/",
        headers: [
          "Forwarded": "for=127.0.0.1"
        ],
        afterResponse: { res async in
          #expect(res.status == .badRequest)
          #expect(res.body.string == "No IP in headers")
        })
    }
  }

  @Test("x-forwarded-for: HEAD returns 200")
  func xForwardedForHead() async throws {
    try await withApp(ipSource: .xForwardedFor) { app in
      try await app.testing().test(
        .HEAD, "/",
        headers: [
          "X-Forwarded-For": "127.0.0.1"
        ],
        afterResponse: { res async in
          #expect(res.status == .ok)
        })
    }
  }

  @Test("forwarded: returns 501 because it's not yet implemented")
  func forwardedNotImplemented() async throws {
    try await withApp(ipSource: .forwarded) { app in
      try await app.testing().test(
        .GET, "/",
        headers: [
          "Forwarded": "for=192.0.2.60"
        ],
        afterResponse: { res async in
          #expect(res.status == .notImplemented)
          #expect(res.body.string == "IP_SOURCE=forwarded is not yet implemented")
        })
    }
  }

  @Test("remote-address: returns the connecting address and ignores headers")
  func remoteAddressIgnoresHeaders() async throws {
    try await withApp(ipSource: .remoteAddress) { app in
      // A real server on a free port, so the request has a connecting address
      try await app.testing(method: .running(hostname: "127.0.0.1", port: 0)).test(
        .GET, "/",
        headers: [
          "X-Forwarded-For": "1.2.3.4",
          "Forwarded": "for=5.6.7.8",
        ],
        afterResponse: { res async in
          #expect(res.status == .ok)
          #expect(res.body.string == "127.0.0.1")
        })
    }
  }
}

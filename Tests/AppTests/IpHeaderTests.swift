import Testing
import VaporTesting

@testable import App

@Suite("IP Header Tests")
struct IpHeaderTests {

  // support thingie
  private func withApp(_ test: (Application) async throws -> Void) async throws {
    let app = try await Application.make(.testing)
    do {
      try await configure(app, env: .testing)
      try await test(app)
    } catch {
      try await app.asyncShutdown()
      throw error
    }
    try await app.asyncShutdown()
  }

  @Test("No Headers returns 400 Bad Request")
  func rootRoute_MissingHeaders() async throws {
    try await withApp { app in
      try await app.testing().test(
        .GET, "/",
        afterResponse: { res async in
          #expect(res.status == .badRequest)
          #expect(res.body.string == "No IP in headers")
        })
    }
  }

  @Test("Header 'Forwarded' returns 400 Bad Request (untrusted header)")
  func rootRoute_ForwardedHeader() async throws {
    try await withApp { app in
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

  @Test("Header 'X-Forwarded-For' returns 200 OK with IP")
  func rootRoute_XForwardedForHeader() async throws {
    try await withApp { app in
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

  @Test("Hader 'X-Forwarded-For' Multiple Entries returns 200 OK with first IP")
  func rootRoute_XForwardedForMultipleHeaders() async throws {
    try await withApp { app in
      try await app.testing().test(
        .GET, "/",
        headers: [
          "X-Forwarded-For": "203.0.113.195,2001:db8:85a3:8d3:1319:8a2e:370:7348,198.51.100.178"
        ],
        afterResponse: { res async in
          #expect(res.status == .ok)
          #expect(res.body.string == "203.0.113.195")
        })
    }
  }

  @Test(
    "Other Methods On Root Return 405",
    arguments: [HTTPMethod.POST, .PUT, .DELETE, .OPTIONS, .PATCH])
  func rootOtherMethods(method: HTTPMethod) async throws {
    try await withApp { app in
      try await app.testing().test(
        method, "/",
        headers: [
          "X-Forwarded-For": "127.0.0.1"
        ],
        afterResponse: { res async in
          #expect(res.status == .methodNotAllowed)
          #expect(res.headers.first(name: .allow) == "GET, HEAD")
          #expect(res.body.string == "Method \(method.rawValue) not allowed")
        })
    }
  }

  @Test(
    "Unknown Paths Return 404",
    arguments: [
      (HTTPMethod.GET, "/hello"), (.POST, "/hello"), (.OPTIONS, "/hello"), (.GET, "/a/b/c"),
    ])
  func unknownPaths(method: HTTPMethod, path: String) async throws {
    try await withApp { app in
      try await app.testing().test(
        method, path,
        headers: [
          "X-Forwarded-For": "127.0.0.1"
        ],
        afterResponse: { res async in
          #expect(res.status == .notFound)
          #expect(res.body.string == "Path \(path) not found")
        })
    }
  }
}

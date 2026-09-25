import Testing
import VaporTesting

@testable import App

/// Unmatched routes and the headers every response gets.
@Suite("Routing Tests")
struct RoutingTests {

  @Test(
    "Other methods on root return 405",
    arguments: [HTTPMethod.POST, .PUT, .DELETE, .OPTIONS, .PATCH])
  func rootOtherMethods(method: HTTPMethod) async throws {
    try await withApp(ipSource: .xForwardedFor) { app in
      try await app.testing().test(
        method, "/",
        afterResponse: { res async in
          #expect(res.status == .methodNotAllowed)
          #expect(res.headers.first(name: .allow) == "GET, HEAD")
          #expect(res.body.string == "Method \(method.rawValue) not allowed")
        })
    }
  }

  @Test(
    "Unknown paths return 404",
    arguments: [
      (HTTPMethod.GET, "/hello"), (.POST, "/hello"), (.OPTIONS, "/hello"), (.GET, "/a/b/c"),
    ])
  func unknownPaths(method: HTTPMethod, path: String) async throws {
    try await withApp(ipSource: .xForwardedFor) { app in
      try await app.testing().test(
        method, path,
        afterResponse: { res async in
          #expect(res.status == .notFound)
          #expect(res.body.string == "Path \(path) not found")
        })
    }
  }

  @Test(
    "Unknown path is shown percent-decoded", arguments: [("/a%20b", "/a b"), ("/%C3%A4", "/ä")])
  func unknownPathDecoded(path: String, shown: String) async throws {
    try await withApp(ipSource: .xForwardedFor) { app in
      try await app.testing().test(
        .GET, path,
        afterResponse: { res async in
          #expect(res.status == .notFound)
          #expect(res.body.string == "Path \(shown) not found")
        })
    }
  }

  @Test(
    "All responses are uncached plain text",
    arguments: [
      (
        IpSource.xForwardedFor, HTTPMethod.GET, "/", ["X-Forwarded-For": "127.0.0.1"], HTTPStatus.ok
      ),
      (.xForwardedFor, .GET, "/", [:], .badRequest),
      (.xForwardedFor, .POST, "/", [:], .methodNotAllowed),
      (.xForwardedFor, .GET, "/hello", [:], .notFound),
      (.forwarded, .GET, "/", [:], .notImplemented),
    ] as [(IpSource, HTTPMethod, String, HTTPHeaders, HTTPStatus)])
  func responseHeaders(
    ipSource: IpSource, method: HTTPMethod, path: String, headers: HTTPHeaders, status: HTTPStatus
  ) async throws {
    try await withApp(ipSource: ipSource) { app in
      try await app.testing().test(
        method, path, headers: headers,
        afterResponse: { res async in
          #expect(res.status == status)
          #expect(res.headers.first(name: .contentType) == "text/plain; charset=utf-8")
          #expect(res.headers.first(name: .cacheControl) == "no-store")
          #expect(res.headers.first(name: .xContentTypeOptions) == "nosniff")
        })
    }
  }
}

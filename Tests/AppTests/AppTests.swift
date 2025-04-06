import Testing
import VaporTesting

@testable import App

@Suite("App Tests")
struct AppTests {
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

  @Test("Test Root Route With Missing Header")
  func rootRouteMissing() async throws {
    try await withApp { app in
      try await app.testing().test(
        .GET, "/",
        afterResponse: { res async in
          #expect(res.status == .internalServerError)
          #expect(res.body.string == "Client IP not found in headers")
        })
    }
  }

  @Test("Test Root Route With Forwarded Header is not handled")
  func rootRouteForwared() async throws {
    try await withApp { app in
      try await app.testing().test(
        .GET, "/", headers: ["Forwarded": "for=127.0.0.1"],
        afterResponse: { res async in
          #expect(res.status == .internalServerError)
          #expect(res.body.string == "Client IP not found in headers")
        })
    }
  }

  @Test("Test Root Route With X-Forwarded-For Header")
  func rootRouteXForwardedFor() async throws {
    try await withApp { app in
      try await app.testing().test(
        .GET, "/", headers: ["X-Forwarded-For": "127.0.0.1"],
        afterResponse: { res async in
          #expect(res.status == .ok)
          #expect(res.body.string == "127.0.0.1")
        })
    }
  }

  @Test("Test Catch-All Redirect")
  func cathcAllRedirect() async throws {
    try await withApp { app in
      try await app.testing().test(
        .GET, "hello",
        afterResponse: { res async in
          #expect(res.status == .notFound)
          #expect(res.body.string == "")
        })
    }
  }
}

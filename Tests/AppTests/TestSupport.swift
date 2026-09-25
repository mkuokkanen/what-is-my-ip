import VaporTesting

@testable import App

/// Creates and configures an app reading the client IP from `ipSource`, runs `test` with it,
/// and shuts the app down afterwards, also when the test throws.
func withApp(
  ipSource: IpSource, _ test: (Application) async throws -> Void
) async throws {
  let app = try await Application.make(.testing)
  do {
    try await configure(
      app, env: .testing, config: AppConfig(ipSource: ipSource, logHeaders: false))
    try await test(app)
  } catch {
    try await app.asyncShutdown()
    throw error
  }
  try await app.asyncShutdown()
}

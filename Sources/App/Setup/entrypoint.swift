import Logging
import Vapor

@main
enum Entrypoint {
  static func main() async throws {
    var env = try Environment.detect()
    try LoggingSystem.bootstrap(from: &env)

    let app = try await Application.make(env)
    app.logger.info("Application starting, main")

    // This attempts to install NIO as the Swift Concurrency global executor.
    // You can enable it if you'd like to reduce the amount of context switching between NIO and Swift Concurrency.
    // Note: this has caused issues with some libraries that use `.wait()` and cleanly shutting down.
    // If enabled, you should be careful about calling async functions before this point as it can cause assertion failures.
    // let executorTakeoverSuccess = NIOSingletons.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
    // app.logger.debug("Tried to install SwiftNIO's EventLoopGroup as Swift's global concurrency executor", metadata: ["success": .stringConvertible(executorTakeoverSuccess)])

    // The app is always shut down, also when any step fails
    do {
      // Read settings from environment variables
      let config = try AppConfig.fromEnvironment()
      app.logger.info("Configuration: \(config)")

      // Set up middleware and routes
      try await configure(app, env: env, config: config)

      // Start the application; returns when it's stopped
      try await app.execute()

      // Normal shutdown
      try await app.asyncShutdown()
    } catch {
      // Log the error and shut down the app, then rethrow the error to exit with a non-zero status code
      app.logger.report(error: error)
      try? await app.asyncShutdown()
      throw error
    }
  }
}

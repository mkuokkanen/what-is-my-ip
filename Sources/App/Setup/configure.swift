import Vapor

/// Configures the application: stores the settings, sets up middleware and registers routes.
func configure(_ app: Application, env: Environment, config: AppConfig) async throws {
  app.appConfig = config

  // Clear all default middleware
  app.middleware = .init()

  // Middleware runs in the order it is listed here
  app.middleware.use(RouteLoggingMiddleware(logLevel: .info))
  app.middleware.use(ErrorMiddleware.default(environment: env))
  app.middleware.use(UnmatchedRouteMiddleware())

  // Header logging is for debugging only (logs at debug level)
  if app.appConfig.logHeaders {
    app.middleware.use(HeaderLoggerMiddleware())
  }

  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  // register routes
  try routes(app)
}

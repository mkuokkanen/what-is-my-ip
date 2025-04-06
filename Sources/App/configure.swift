import Vapor

// configures your application
public func configure(_ app: Application, env: Environment) async throws {
  app.logger.debug("Application starting, configure")

  // Clear all default middleware
  app.middleware = .init()
  app.middleware.use(RouteLoggingMiddleware(logLevel: .info))
  app.middleware.use(ErrorMiddleware.default(environment: env))
  app.middleware.use(HeaderLoggerMiddleware())

  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  // register routes
  try routes(app)
}

import Vapor

func routes(_ app: Application) throws {
  // root; all other paths and methods are answered by UnmatchedRouteMiddleware
  app.get(use: handleIpRequest)
}

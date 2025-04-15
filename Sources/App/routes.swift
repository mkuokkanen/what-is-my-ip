import Vapor

func routes(_ app: Application) throws {
  // root
  app.on(.GET, "", use: handleIpRequest)

  // root - other methods
  app.on(.POST, "", use: returnNotFound)
  app.on(.PATCH, "", use: returnNotFound)
  app.on(.PUT, "", use: returnNotFound)
  app.on(.DELETE, "", use: returnNotFound)

  // all paths except roots
  app.on(.GET, PathComponent.catchall, use: returnNotFound)
  app.on(.POST, PathComponent.catchall, use: returnNotFound)
  app.on(.PATCH, PathComponent.catchall, use: returnNotFound)
  app.on(.PUT, PathComponent.catchall, use: returnNotFound)
  app.on(.DELETE, PathComponent.catchall, use: returnNotFound)
}

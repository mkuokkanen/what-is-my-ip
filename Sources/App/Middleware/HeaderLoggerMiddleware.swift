import Vapor

/// Middleware that logs all request headers at debug level.
/// For debugging only, not for production use.
final class HeaderLoggerMiddleware: AsyncMiddleware {
  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
    // Log all request headers
    for (name, value) in request.headers {
      request.logger.debug("Header \(name): \(value)")
    }

    // Continue to the next middleware or handler
    return try await next.respond(to: request)
  }
}

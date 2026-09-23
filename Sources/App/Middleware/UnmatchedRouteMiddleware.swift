import Vapor

/// Answers requests that don't match a route with a plain text response,
/// instead of Vapor's default JSON error body:
/// - 405 Method Not Allowed, with an Allow header, for other methods on "/"
/// - 404 Not Found otherwise
final class UnmatchedRouteMiddleware: AsyncMiddleware {
  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
    do {
      return try await next.respond(to: request)
    } catch let error as AbortError where error.status == .notFound {
      // "/" is the only route, registered for GET (Vapor also answers HEAD with it)
      if request.url.path == "/" {
        return methodNotAllowed(request)
      }
      return notFound(request)
    }
  }

  private func methodNotAllowed(_ request: Request) -> Response {
    var headers = HTTPHeaders()
    headers.add(name: .contentType, value: "text/plain")
    headers.add(name: .allow, value: "GET, HEAD")
    return Response(
      status: .methodNotAllowed, headers: headers,
      body: .init(string: "Method \(request.method.rawValue) not allowed"))
  }

  private func notFound(_ request: Request) -> Response {
    var headers = HTTPHeaders()
    headers.add(name: .contentType, value: "text/plain")
    // Vapor returns the path percent-encoded; decode it to show it as the client sent it
    let path = request.url.path.removingPercentEncoding ?? request.url.path
    return Response(
      status: .notFound, headers: headers,
      body: .init(string: "Path \(path) not found"))
  }
}

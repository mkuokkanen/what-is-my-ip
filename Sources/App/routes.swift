import Vapor

func routes(_ app: Application) throws {
    // root
    app.on(.GET, "", use: clientIpFromXForwardedFor)
    
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

/// Fetches client ip from X-Forwarded-For header.
/// Helper method .forwarded looks nice but it presumes that both Forwarded and X-Forwarded-For
/// can be trusted and gives Forwarded header priority.
/// Traefik manages only X-Forwarded-For, so client could fake result by sending Forwarded header
@Sendable
func clientIpFromXForwardedFor(_ req: Request) async throws -> Response {
    // response headers
    var headers = HTTPHeaders()
    headers.add(name: .contentType, value: "text/plain")
    
    // response status and body
    let statusCode: HTTPResponseStatus
    let responseStr: String
    if let xForwardedFor = req.headers["X-Forwarded-For"].first {
        req.logger.debug("Client IP (X-Forwarded-For): \(xForwardedFor)")
        statusCode = .ok
        responseStr = xForwardedFor
    } else {
        statusCode = .internalServerError
        responseStr = "Client IP not found in headers"
    }
    
    // build response
    return Response(
        status: statusCode,
        headers: headers,
        body: .init(string: responseStr)
    )
}

/// Returns 404 Not Found response
@Sendable
func returnNotFound(_ req: Request) async throws -> Response {
    return Response(status: .notFound)
}

import Vapor

/// Returns the IP address from the request headers
@Sendable
func handleIpRequest(_ req: Request) async throws -> Response {
  guard let ip = await ipFromHeaders(req) else {
    req.logger.error("No IP in headers")
    return textResponse(.badRequest, "No IP in headers")
  }

  return textResponse(.ok, ip)
}

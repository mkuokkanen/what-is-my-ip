import Vapor

/// Returns the client IP, read from the source chosen with IP_SOURCE
@Sendable
func handleIpRequest(_ req: Request) -> Response {
  let source = req.application.appConfig.ipSource
  let clientIp: String?
  do {
    clientIp = try source.clientIp(req)
  } catch {
    // clientIp only throws NotYetImplemented (typed throws), so no type check is needed
    req.logger.warning("\(error)")
    return textResponse(.notImplemented, error.description)
  }

  guard let ip = clientIp else {
    req.logger.error("No client IP found (IP_SOURCE: \(source.rawValue))")
    return textResponse(.badRequest, "No IP in headers")
  }

  return textResponse(.ok, ip)
}

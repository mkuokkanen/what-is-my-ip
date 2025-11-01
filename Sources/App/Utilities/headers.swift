import Vapor

/// Fetches client ip from X-Forwarded-For header.
/// Helper method .forwarded looks nice but it presumes that both Forwarded and X-Forwarded-For
/// can be trusted and gives Forwarded header priority.
/// Traefik manages only X-Forwarded-For, so client could fake result by sending Forwarded header
func ipFromHeaders(_ req: Request) async -> String? {

  // ignore Forwarded header
  if let forwardedHeader: String = req.headers["Forwarded"].first {
    req.logger.warning("Ignoring untrusted Forwarded header: \(forwardedHeader)")
  }

  if let xForwardedFor: String = req.headers["X-Forwarded-For"].first {
    let clientIp =
      xForwardedFor
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .first ?? ""
    req.logger.debug("Client IP (X-Forwarded-For): \(clientIp)")
    return clientIp
  } else {
    return nil
  }
}

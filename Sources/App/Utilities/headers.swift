import Vapor

/// Returns the client IP from the X-Forwarded-For header, or nil if the header is missing.
///
/// The app runs only behind Traefik, which by default removes any X-Forwarded-For sent by
/// the client and sets it to the connecting client's IP, so the value can be trusted.
///
/// Vapor's `req.headers.forwarded` is not used: it lists Forwarded header entries before
/// X-Forwarded-For entries. Traefik manages only X-Forwarded-For and passes the Forwarded
/// header through unchanged, so a client could fake the result by sending Forwarded.
///
/// If the app is run behind a different proxy, this method may need to be updated.
func ipFromHeaders(_ req: Request) async -> String? {

  // Traefik passes a client-sent Forwarded header through unchanged; it is not trusted.
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

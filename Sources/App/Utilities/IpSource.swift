import Vapor

/// Where the client IP is read from. Chosen at startup with the IP_SOURCE environment variable.
enum IpSource: String, CaseIterable {
  /// X-Forwarded-For header, as set by Traefik
  case xForwardedFor = "x-forwarded-for"
  /// Forwarded header (RFC 7239). Not yet implemented, requests fail with 501.
  case forwarded = "forwarded"
  /// Address of the connecting client, for running without a proxy
  case remoteAddress = "remote-address"

  /// Parses an IP_SOURCE value. Returns nil if the value is missing, throws if it's unknown.
  static func parse(_ value: String?) throws -> IpSource? {
    guard let value else {
      return nil
    }
    guard let source = IpSource(rawValue: value) else {
      throw InvalidIpSource(value: value)
    }
    return source
  }

  /// Returns the client IP from this source, or nil if it's not available.
  /// Throws for a source that is not yet implemented.
  func clientIp(_ req: Request) throws(NotYetImplemented) -> String? {
    switch self {
    case .xForwardedFor: ipFromXForwardedFor(req)
    case .forwarded: throw NotYetImplemented(feature: "IP_SOURCE=forwarded")
    case .remoteAddress: req.remoteAddress?.ipAddress
    }
  }
}

/// Returns the client IP from the X-Forwarded-For header, or nil if the header is missing.
///
/// Traefik by default removes any X-Forwarded-For sent by the client and sets it to the
/// connecting client's IP, so behind Traefik the value can be trusted.
///
/// Vapor's `req.headers.forwarded` is not used: it lists Forwarded header entries before
/// X-Forwarded-For entries, and Traefik passes a client-sent Forwarded header through unchanged.
private func ipFromXForwardedFor(_ req: Request) -> String? {
  if let xForwardedFor = req.headers.first(name: .xForwardedFor) {
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

/// Error when the IP_SOURCE environment variable is set to an unknown value.
struct InvalidIpSource: Error, CustomStringConvertible {
  let value: String

  var description: String {
    let allowed = IpSource.allCases.map(\.rawValue).joined(separator: ", ")
    return "Invalid IP_SOURCE '\(value)', expected one of: \(allowed)"
  }
}

/// A feature that is recognised, but not yet implemented.
struct NotYetImplemented: Error, CustomStringConvertible {
  let feature: String

  var description: String {
    "\(feature) is not yet implemented"
  }
}

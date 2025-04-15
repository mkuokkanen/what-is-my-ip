import Vapor

/// Returns 404 Not Found response
@Sendable
func returnNotFound(_ req: Request) async throws -> Response {
  return Response(status: .notFound)
}

/// Returns the IP address from the request headers
@Sendable
func handleIpRequest(_ req: Request) async throws -> Response {
  guard let ip = await ipFromHeaders(req) else {
    req.logger.error("No IP in headers")
    return Response(
      status: .badRequest,
      body: "No IP in headers")
  }

  return await handleText(ip)
}

private func handleText(_ ip: String) async -> Response {
  // header
  var headers = HTTPHeaders()
  headers.add(name: .contentType, value: "text/plain")

  // body
  let response = Response(status: .ok, headers: headers, body: .init(string: ip))
  return response
}

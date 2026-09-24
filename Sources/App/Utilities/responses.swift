import Vapor

/// Creates a plain text response.
func textResponse(
  _ status: HTTPResponseStatus, _ text: String, headers: HTTPHeaders = [:]
) -> Response {
  var headers = headers
  headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
  headers.replaceOrAdd(name: .cacheControl, value: "no-store")
  headers.replaceOrAdd(name: .xContentTypeOptions, value: "nosniff")
  return Response(status: status, headers: headers, body: .init(string: text))
}

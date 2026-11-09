import Foundation
import OAuthenticator
import Testing

private let issuer = "https://login.example.com"
private let tokenJSON = """
{"access_token":"test-token","sub":"did:plc:abcdefghijklmnopqrstuvwx","scope":"atproto","token_type":"DPoP","expires_in":300}
"""

@Test func validBlueskyTokenExchangeControl() async throws {
    let recorder = ResponseRecorder(body: tokenJSON)
    let handling = try makeHandling()
    let login = try await handling.loginProvider(parameters(
        callback: "com.example.app:/callback?code=example&state=expected&iss=https://login.example.com",
        recorder: recorder))
    #expect(login.accessToken.value == "test-token")
}

@Test func issuerMismatchMustBeRejectedBeforeTokenExchange() async throws {
    let recorder = ResponseRecorder(body: tokenJSON)
    let handling = try makeHandling()
    await #expect(throws: AuthenticatorError.issuingServerMismatch("https://attacker.example.com", issuer)) {
        try await handling.loginProvider(parameters(
            callback: "com.example.app:/callback?code=example&state=expected&iss=https://attacker.example.com",
            recorder: recorder))
    }
    #expect(await recorder.requests.isEmpty)
}

@Test func successfulWriteWithANewNonceMustNotBeReplayed() async throws {
    let recorder = ResponseRecorder(body: "{}", status: 201)
    try await DPoPProbe().performWrite(using: recorder)
    #expect(await recorder.requests.count == 1)
}

@Test func parMustPreserveTheExactClientIdentifier() async throws {
    let clientID = "https://app.example.com/client.json?channel=dev&platform=ios"
    let recorder = ResponseRecorder(body: "{\"request_uri\":\"urn:probe\",\"expires_in\":600}", status: 201)
    let configuration = Authenticator.Configuration(appCredentials: credentials(clientID: clientID),
        tokenHandling: try makeHandling(), mode: .manualOnly,
        userAuthenticator: { _, _ in throw CancellationError() })
    let authenticator = Authenticator(config: configuration,
        urlLoader: { await recorder.response(for: $0) })
    await #expect(throws: CancellationError.self) { try await authenticator.authenticate() }
    let request = try #require(await recorder.requests.first)
    let body = try #require(request.httpBody)
    let fields = try #require(URLComponents(string: "https://example.com/?" + String(decoding: body, as: UTF8.self)))
    #expect(fields.queryItems?.first(where: { $0.name == "client_id" })?.value == clientID)
}

private func parameters(callback: String, recorder: ResponseRecorder) -> TokenHandling.LoginProviderParameters {
        TokenHandling.LoginProviderParameters(
        authorizationURL: URL(string: issuer + "/authorize")!, credentials: credentials(),
        redirectURL: URL(string: callback)!, responseProvider: { await recorder.response(for: $0) },
        stateToken: "expected", pkce: PKCEVerifier())

}

private func credentials(clientID: String = "https://app.example.com/client.json") -> AppCredentials {
    AppCredentials(clientId: clientID, clientPassword: "", scopes: ["atproto"],
        callbackURL: URL(string: "com.example.app:/callback")!)
}

private func makeHandling() throws -> TokenHandling {
    let metadata = """
    {
      "issuer":"https://login.example.com",
      "authorization_endpoint":"https://login.example.com/authorize",
      "token_endpoint":"https://login.example.com/token",
      "response_types_supported":["code"],
      "grant_types_supported":["authorization_code","refresh_token"],
      "code_challenge_methods_supported":["S256"],
      "token_endpoint_auth_methods_supported":["none"],
      "token_endpoint_auth_signing_alg_values_supported":["ES256"],
      "scopes_supported":["atproto"],
      "authorization_response_iss_parameter_supported":true,
      "require_pushed_authorization_requests":true,
      "pushed_authorization_request_endpoint":"https://login.example.com/par",
      "dpop_signing_alg_values_supported":["ES256"],
      "require_request_uri_registration":true,
      "client_id_metadata_document_supported":true
    }
    """
    let server = try JSONDecoder().decode(ServerMetadata.self, from: Data(metadata.utf8))
    // Identity validation is intentionally successful so these probes isolate
    // issuer ordering, nonce replay, and form serialization in the dependency.
    return Bluesky.tokenHandling(account: nil, server: server,
        jwtGenerator: { _ in "test-only-proof" }, validator: { _, _ in true })
}

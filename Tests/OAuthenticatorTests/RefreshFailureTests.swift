import Foundation
import OAuthenticator
import Testing

@Test(arguments: [false, true])
func refreshClearsOnlyConfirmedInvalidGrants(terminal: Bool) async throws {
    let store = RefreshStorage()
    let handling = TokenHandling(authorizationURLProvider: { _ in throw CancellationError() },
        loginProvider: { _ in throw CancellationError() }, refreshProvider: { _, _, _ in
            if terminal { throw AuthenticatorError.invalidGrant("invalid_grant", "") }
            throw URLError(.notConnectedToInternet)
        })
    let config = Authenticator.Configuration(
        appCredentials: AppCredentials(clientId: "test", clientPassword: "", scopes: [],
            callbackURL: URL(string: "test:/callback")!),
        loginStorage: LoginStorage(retrieveLogin: { await store.load() },
            storeLogin: { await store.save($0) }, clearLogin: { await store.clear() }),
        tokenHandling: handling, mode: .manualOnly,
        userAuthenticator: { _, _ in throw CancellationError() })
    let auth = Authenticator(config: config)
    await #expect(throws: (any Error).self) {
        try await auth.response(for: URLRequest(url: URL(string: "https://example.com")!))
    }
    #expect(await store.clears == (terminal ? 1 : 0))
    #expect(await store.load() != nil || terminal)
}

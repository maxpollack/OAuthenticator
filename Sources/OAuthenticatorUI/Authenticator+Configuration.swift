#if canImport(AuthenticationServices)
import AuthenticationServices
import Foundation
import OAuthenticator

extension Authenticator.Configuration {
    /// Optional system-browser integration. Import OAuthenticatorUI to opt in;
    /// protocol-only clients supply their own userAuthenticator to the core.
    @available(tvOS 16.0, macCatalyst 13.0, *)
    public init(appCredentials: AppCredentials, loginStorage: LoginStorage? = nil,
                tokenHandling: TokenHandling, mode: Authenticator.UserAuthenticationMode = .automatic,
                authenticationStatusHandler: Authenticator.AuthenticationStatusHandler? = nil) {
        self.init(appCredentials: appCredentials, loginStorage: loginStorage,
                  tokenHandling: tokenHandling, mode: mode,
                  userAuthenticator: { try await ASWebAuthenticationSession.userAuthenticator(url: $0, scheme: $1) },
                  authenticationStatusHandler: authenticationStatusHandler)
    }
}
#endif

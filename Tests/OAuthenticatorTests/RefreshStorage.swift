import Foundation
import OAuthenticator

actor RefreshStorage {
    var login: Login?
    var clears = 0
    init() {
        login = Login(accessToken: Token(value: "expired", expiry: .distantPast),
            refreshToken: Token(value: "refresh"))
    }
    func load() -> Login? { login }
    func save(_ value: Login) { login = value }
    func clear() { clears += 1; login = nil }
}

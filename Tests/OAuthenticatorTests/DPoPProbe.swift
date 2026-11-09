import Foundation
import OAuthenticator

actor DPoPProbe {
    private let signer = DPoPSigner()

    func performWrite(using recorder: ResponseRecorder) async throws {
        var request = URLRequest(url: URL(string: "https://pds.example.com/xrpc/example.write")!)
        request.httpMethod = "POST"
                _ = try await signer.response(isolation: self, for: request,
            using: { _ in "test-only-proof" }, token: "test-only-token", tokenHash: "test-only-hash",
            isAuthServer: false, responseProvider: { await recorder.response(for: $0) })

    }
}

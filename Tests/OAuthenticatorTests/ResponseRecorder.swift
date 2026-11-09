import Foundation

actor ResponseRecorder {
    let body: String
    let status: Int
    private(set) var requests: [URLRequest] = []

    init(body: String, status: Int = 200) {
        self.body = body
        self.status = status
    }

    func response(for request: URLRequest) -> (Data, URLResponse) {
        requests.append(request)
        let response = HTTPURLResponse(url: request.url!, statusCode: status,
            httpVersion: "HTTP/1.1", headerFields: [
                "Content-Type": "application/json", "DPoP-Nonce": "fresh-test-nonce"
            ])!
        return (Data(body.utf8), response)
    }
}

import Foundation

enum FormURLEncoder {
    static func encode(_ values: [String: String]) -> Data {
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        let pairs = values.sorted { $0.key < $1.key }.map {
            $0.key.addingPercentEncoding(withAllowedCharacters: allowed)! + "="
                + $0.value.addingPercentEncoding(withAllowedCharacters: allowed)!
        }
        return Data(pairs.joined(separator: "&").utf8)
    }
}

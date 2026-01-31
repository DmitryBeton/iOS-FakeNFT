import Foundation

enum RequestConstants {
    static let baseURL = "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net"
    static let token = getToken()
    
    private static func getToken() -> String {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let dict = try? NSDictionary(contentsOf: url, error: ()) as? [String: Any],
              let token = dict["API_TOKEN"] as? String
        else {
            assertionFailure(
                """
                ⚠️
                Secrets.plist is missing.
                Create Secrets.plist (see Secrets.example.plist) and add it to path FakeNFT/Resources.
                """
            )
            return ""
        }
        return token
    }
}

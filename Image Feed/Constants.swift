import Foundation
enum Constants {
    static let accessKey = "PQD8ifqlqe-8a7qYekE_8a6oogGkwVuxct2x8VDVafE"
    static let secretKey = "sT-xpu88gVeiuS19WziFG6JIZYfRs5GtEDXCd7kWkt4"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Failed to create default base URL")
        }
        return url
    }()
}

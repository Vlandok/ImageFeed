import Foundation
import UIKit

struct UrlsResult: Decodable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let likes: Int?
    let likedByUser: Bool
    let welcomeDescription: String?
    let urls: UrlsResult

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likes
        case likedByUser = "liked_by_user"
        case welcomeDescription = "description"
        case urls
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    init(result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = result.createdAt
        self.welcomeDescription = result.welcomeDescription
        self.thumbImageURL = result.urls.thumb ?? result.urls.small ?? result.urls.regular ?? ""
        self.largeImageURL = result.urls.full ?? result.urls.regular ?? result.urls.raw ?? ""
        self.isLiked = result.likedByUser
    }
}

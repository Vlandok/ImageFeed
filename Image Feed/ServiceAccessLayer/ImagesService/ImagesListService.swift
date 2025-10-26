import Foundation

final class ImagesListService {
    static let shared = ImagesListService()

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []

    private let urlSession = URLSession.shared
    private var lastLoadedPage: Int?
    private var isLoading: Bool = false
    private let perPage: Int = 10

    private init() {}

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard !isLoading else { return }

        let nextPage = (lastLoadedPage ?? 0) + 1

        guard let request = makePhotosRequest(page: nextPage, perPage: perPage) else { return }

        isLoading = true

        let task = urlSession.data(for: request) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let results = try decoder.decode([PhotoResult].self, from: data)
                    let newPhotos = results.map { Photo(result: $0) }
                    DispatchQueue.main.async {
                        self.photos.append(contentsOf: newPhotos)
                        self.lastLoadedPage = nextPage
                        self.isLoading = false
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    }
                } catch {
                    print("[ImagesListService] Decoding error: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            case .failure(let error):
                print("[ImagesListService] Network error: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
        task.resume()
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard let request = makeChangeLikeRequest(photoId: photoId, isLike: isLike) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = urlSession.data(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }

    private func makePhotosRequest(page: Int, perPage: Int) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else { return nil }

        var components = URLComponents(url: Constants.defaultBaseURL.appendingPathComponent("/photos"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]

        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func makeChangeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else { return nil }

        let url = Constants.defaultBaseURL.appendingPathComponent("/photos/\(photoId)/like")
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func reset() {
        lastLoadedPage = nil
        isLoading = false
        photos = []
    }
}

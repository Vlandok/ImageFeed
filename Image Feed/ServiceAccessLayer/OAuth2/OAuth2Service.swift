import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private var task: URLSessionTask?

    private var lastCode: String?
    
    
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code
        let request = makeOAuthTokenRequest(code: code)
        guard let request = request else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            print("[OAuth2Service] Ошибка создания запроса: \(error)")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let oauthTokenResponse):
                OAuth2TokenStorage.shared.token = oauthTokenResponse.accessToken
                print("[OAuth2Service] Токен успешно получен и сохранен")
                self.task = nil
                self.lastCode = nil
                completion(.success(oauthTokenResponse.accessToken))
            case .failure(let error):
                print("[OAuth2Service] Ошибка получения токена: \(error)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
}

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        guard let request = request else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            print("[OAuth2Service] Ошибка создания запроса: \(error)")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let oauthTokenResponse = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage.shared.token = oauthTokenResponse.accessToken
                    print("[OAuth2Service] Токен успешно получен и сохранен")
                    DispatchQueue.main.async {
                        completion(.success(oauthTokenResponse.accessToken))
                    }
                } catch {
                    print("[OAuth2Service] Ошибка декодирования ответа: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("[OAuth2Service] Сетевая ошибка: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
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

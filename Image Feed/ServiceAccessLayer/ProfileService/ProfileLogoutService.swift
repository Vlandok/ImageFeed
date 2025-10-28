import Foundation
import WebKit
import UIKit

protocol ProfileLogoutService {
    func logout()
}

final class ProfileLogoutServiceImpl: ProfileLogoutService {
    static let shared = ProfileLogoutServiceImpl()
    
    private init() { }
    
    func logout() {
        clearAuth()
        cleanCookies()
        resetServices()
        switchToSplash()
    }
    
    private func clearAuth() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func resetServices() {
        ProfileServiceImpl.shared.reset()
        ProfileImageServiceImpl.shared.reset()
        ImagesListServiceImpl.shared.reset()
    }
    
    private func switchToSplash() {
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = SplashViewController()
    }
}

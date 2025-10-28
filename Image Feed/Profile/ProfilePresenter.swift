import Foundation

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileService
    private let imageService: ProfileImageService
    private let logoutService: ProfileLogoutService
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(
        profileService: ProfileService,
        imageService: ProfileImageService,
        logoutService: ProfileLogoutService
    ) {
        self.profileService = profileService
        self.imageService = imageService
        self.logoutService = logoutService
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func viewDidLoad() {
        view?.initUiScreen()
        
        if let profile = profileService.profile {
            let profileUiModel = ProfileUiModel(
                name: profile.name,
                login: profile.loginName,
                bio: profile.bio,
                avatarURL: imageService.avatarURL
            )
            view?.setProfile(profile: profileUiModel)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageServiceImpl.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self = self else { return }
                if let avatarUrl = notification.userInfo?["URL"] as? String {
                    self.view?.setAvatar(url: avatarUrl)
                }
            }
    }
    
    func didTapLogout() {
        view?.showLogoutAlert { [weak self] in
            self?.logoutService.logout()
        }
    }
}

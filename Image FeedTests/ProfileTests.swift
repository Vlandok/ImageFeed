@testable import Image_Feed
import XCTest

final class ProfileTests: XCTestCase {

    func testViewDidLoadDisplaysProfileAndAvatar() {
        // given
        let profile = Profile(username: "john", name: "John Doe", loginName: "@john", bio: "bio")
        let profileService = ProfileDataServiceMock(profile: profile)
        let imageService = ProfileImageServiceMock(avatarURL: "https://example.com/avatar.png")
        let logoutService = ProfileLogoutServiceMock()
        let presenter = ProfilePresenter(profileService: profileService, imageService: imageService, logoutService: logoutService)
        let view = ProfileViewSpy()
        presenter.view = view

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertTrue(view.initUiScreenCalled)
        XCTAssertTrue(view.setProfileCalled)
        XCTAssertEqual(view.setAvatarCalledWith, "https://example.com/avatar.png")
    }

    func testAvatarNotificationUpdatesView() {
        // given
        let profile = Profile(username: "john", name: "John Doe", loginName: "@john", bio: "bio")
        let profileService = ProfileDataServiceMock(profile: profile)
        let imageService = ProfileImageServiceMock(avatarURL: nil)
        let logoutService = ProfileLogoutServiceMock()
        let presenter = ProfilePresenter(profileService: profileService, imageService: imageService, logoutService: logoutService)
        let view = ProfileViewSpy()
        presenter.view = view

        presenter.viewDidLoad()

        // when
        NotificationCenter.default.post(name: ProfileImageServiceImpl.didChangeNotification, object: nil, userInfo: ["URL": "https://example.com/new.png"])

        // then
        XCTAssertEqual(view.setAvatarCalledWith, "https://example.com/new.png")
    }

    func testDidTapLogoutShowsAlertAndCallsLogoutOnConfirm() {
        // given
        let profileService = ProfileDataServiceMock(profile: nil)
        let imageService = ProfileImageServiceMock(avatarURL: nil)
        let logoutService = ProfileLogoutServiceMock()
        let presenter = ProfilePresenter(profileService: profileService, imageService: imageService, logoutService: logoutService)
        let view = ProfileViewSpy()
        presenter.view = view

        // when
        presenter.didTapLogout()
        view.confirmLogout?()

        // then
        XCTAssertTrue(view.showLogoutAlertCalled)
        XCTAssertTrue(logoutService.logoutCalled)
    }
}

private final class ProfileViewSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var initUiScreenCalled = false
    var setProfileCalled = false
    var setAvatarCalledWith: String?
    var showLogoutAlertCalled = false
    var confirmLogout: (() -> Void)?

    func initUiScreen() {
        initUiScreenCalled = true
    }

    func setProfile(profile: Image_Feed.ProfileUiModel) {
        setProfileCalled = true
        if let url = profile.avatarURL {
            setAvatar(url: url)
        }
    }

    func setAvatar(url: String) {
        setAvatarCalledWith = url
    }

    func showLogoutAlert(onConfirm: @escaping () -> Void) {
        showLogoutAlertCalled = true
        confirmLogout = onConfirm
    }
}

private struct ProfileDataServiceMock: ProfileService {
    let profile: Profile?
}

private struct ProfileImageServiceMock: ProfileImageService {
    let avatarURL: String?
}

private final class ProfileLogoutServiceMock: ProfileLogoutService {
    private(set) var logoutCalled = false
    func logout() { logoutCalled = true }
}

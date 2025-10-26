import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let imagesRouter = ImagesListRouterImpl(sourceViewController: imagesListViewController)
        let imagesPresenter = ImagesListPresenter(imagesService: ImagesListServiceImpl.shared, router: imagesRouter)
        imagesListViewController.presenter = imagesPresenter
        imagesPresenter.view = imagesListViewController
        let profileViewController = ProfileViewController()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceImpl.shared,
            imageService: ProfileImageServiceImpl.shared,
            logoutService: ProfileLogoutServiceImpl.shared
        )
        presenter.view = profileViewController
        profileViewController.presenter = presenter
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}

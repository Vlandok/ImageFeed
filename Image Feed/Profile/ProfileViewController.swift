import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func initUiScreen()
    func setProfile(profile: ProfileUiModel)
    func setAvatar(url: String)
    func showLogoutAlert(onConfirm: @escaping () -> Void)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol?
    
    private let defaultAvatarImage: UIImage = {
        let avatar = UIImage(resource: .avatarPlaceholder)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        return avatar
    }()
    
    private lazy var photoProfile: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = defaultAvatarImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let userName: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "userNameLabel"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userNickName: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "userNickLabel"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionProfile: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.accessibilityIdentifier = "logoutButton"
        button.setImage(UIImage(resource: .logoutButton), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }
    
    func initUiScreen() {
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        view.addSubview(photoProfile)
        view.addSubview(userName)
        view.addSubview(userNickName)
        view.addSubview(descriptionProfile)
        view.addSubview(exitButton)
        
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            getPhotoAnchors() +
            getNameAnchors() +
            getNicknameAnchors() +
            getDescriptionAnchors() +
            getExitAnchors()
        )
    }
    
    private func getPhotoAnchors() -> [NSLayoutConstraint]{
        return [photoProfile.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                photoProfile.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                photoProfile.widthAnchor.constraint(equalToConstant: 70),
                photoProfile.heightAnchor.constraint(equalToConstant: 70)]
    }
    
    private func getNameAnchors() -> [NSLayoutConstraint]{
        return [userName.topAnchor.constraint(equalTo: photoProfile.bottomAnchor, constant: 8),
                userName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)]
    }
    
    private func getNicknameAnchors() -> [NSLayoutConstraint]{
        return [userNickName.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
                userNickName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)]
    }
    
    private func getDescriptionAnchors() -> [NSLayoutConstraint]{
        return [descriptionProfile.topAnchor.constraint(equalTo: userNickName.bottomAnchor, constant: 8),
                descriptionProfile.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                descriptionProfile.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)]
    }
    
    private func getExitAnchors() -> [NSLayoutConstraint]{
        return [exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
                exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                exitButton.widthAnchor.constraint(equalToConstant: 44),
                exitButton.heightAnchor.constraint(equalToConstant: 44)]
    }
    
    func setProfile(profile: ProfileUiModel) {
        userName.text = profile.nameText
        userNickName.text = profile.loginText
        descriptionProfile.text = profile.bioText
        if let url = profile.avatarURL {
            setAvatar(url: url)
        }
    }
    
    func setAvatar(url: String) {
        guard let url = URL(string: url) else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        photoProfile.kf.indicatorType = .activity
        photoProfile.kf.setImage(
            with: url,
            placeholder: defaultAvatarImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ])
    }
    
    func showLogoutAlert(onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { _ in
            onConfirm()
        }))
        present(alert, animated: true)
    }
    
    @objc private func exitButtonTapped() {
        presenter?.didTapLogout()
    }
}

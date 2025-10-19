import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
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
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userNickName: UILabel = {
        let label = UILabel()
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
        button.setImage(UIImage(resource: .logoutButton), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
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
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        print("imageUrl: \(url)")
        
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
            ]) { result in
                
                switch result {
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func updateProfileDetails(profile: Profile) {
        userName.text = profile.name.isEmpty
        ? "Имя не указано"
        : profile.name
        userNickName.text = profile.loginName.isEmpty
        ? "@неизвестный_пользователь"
        : profile.loginName
        descriptionProfile.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : profile.bio
    }
    
    @objc private func exitButtonTapped() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { _ in
            ProfileLogoutService.shared.logout()
        }))
        present(alert, animated: true)
    }
    
}

import UIKit

final class ProfileViewController: UIViewController {
    
    private let photoProfile: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "avatar")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let userName: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.text = "Имя пользователя"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userNickName: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.text = "@nickname"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionProfile: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.text = "Описание профиля"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "yp_black")
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
    
    @objc private func exitButtonTapped() {
        dismiss(animated: true)
    }
    
}

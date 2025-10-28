import Foundation

public struct ProfileUiModel {
    let nameText: String
    let loginText: String
    let bioText: String
    let avatarURL: String?

    init(name: String, login: String, bio: String?, avatarURL: String?) {
        self.nameText = name.isEmpty ? "Имя не указано" : name
        self.loginText = login.isEmpty ? "@неизвестный_пользователь" : login
        self.bioText = (bio?.isEmpty ?? true) ? "Профиль не заполнен" : (bio ?? "")
        self.avatarURL = avatarURL
    }
}

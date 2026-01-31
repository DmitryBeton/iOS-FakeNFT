import Foundation

final class EditProfileViewModel: EditProfileViewModelProtocol {
    
    // MARK: - Bindings
    
    var onStateChange: ((EditProfileState) -> Void)?
    var onAvatarChange: (() -> Void)?
    var onChangesSaved: (() -> Void)?
    
    // MARK: - Public Properties
    
    private(set) var profile: ProfileUI {
        didSet {
            state = .editing
        }
    }
    
    var hasChanges: Bool {
        profile != initialProfile
    }
    
    // MARK: - Public Methods
    
    func loadProfile() {
        state = .initialData(initialProfile)
    }
    
    func changeAvatar(urlString: String) {
        let imageURL = URL(string: urlString)
        guard imageURL != profile.avatarURL else { return }
        profile = ProfileUI(
            name: profile.name,
            avatarURL: imageURL,
            description: profile.description,
            link: profile.link
        )
        onAvatarChange?()
    }
    
    func changeName(_ name: String) {
        profile = ProfileUI(
            name: name,
            avatarURL: profile.avatarURL,
            description: profile.description,
            link: profile.link
        )
    }
    
    func changeDescription(_ description: String) {
        profile = ProfileUI(
            name: profile.name,
            avatarURL: profile.avatarURL,
            description: description,
            link: profile.link
        )
    }
    
    func changeWebsite(urlString: String) {
        profile = ProfileUI(
            name: profile.name,
            avatarURL: profile.avatarURL,
            description: profile.description,
            link: urlString
        )
    }
    
    func saveChanges() {
        state = .saving
        
        let dto = mapToProfileDto(profile)
        service.updateProfile(with: dto) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                state = .saved
                onChangesSaved?()
            case .failure(let error):
                state = .failed
                print("❌[ProfileService] failed to update data, error: \(error)")
            }
        }
    }
    
    // MARK: - State
    
    private var state: EditProfileState = .initial {
        didSet {
            onStateChange?(state)
        }
    }
    
    // MARK: - Private Properties
    
    private let initialProfile: ProfileUI
    private let service: ProfileServiceProtocol
    
    // MARK: - Init
    
    init(profile: ProfileUI, service: ProfileServiceProtocol) {
        initialProfile = profile
        self.profile = profile
        self.service = service
    }
    
    // MARK: - Private Methods
    
    private func mapToProfileDto(_ profileUI: ProfileUI) -> ProfileDto {
        return ProfileDto(
            name: profileUI.name,
            description: profileUI.description,
            avatar: profileUI.avatarURL,
            website: URL(string: profileUI.link)
        )
    }
    
}

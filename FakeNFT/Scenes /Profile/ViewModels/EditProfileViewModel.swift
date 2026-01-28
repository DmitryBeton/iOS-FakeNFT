import Foundation

final class EditProfileViewModel: EditProfileViewModelProtocol {
    
    // MARK: - Bindings
    
    var onStateChange: ((EditProfileState) -> Void)?
    
    // MARK: - Public Properties
    
    private(set) var profile: ProfileUI {
        didSet {
            state = .editing(profile, isDifferentFromInitial)
        }
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
    
    // TODO: Should be changed with service implementation
    func saveChanges() {
        state = .saving
        state = .saved
    }
    
    // MARK: - State
    
    private var state: EditProfileState = .initial {
        didSet {
            onStateChange?(state)
        }
    }
    
    // MARK: - Private Properties
    
    private let initialProfile: ProfileUI
    
    private var isDifferentFromInitial: Bool {
        profile != initialProfile
    }
    
    // MARK: - Init
    
    init(profile: ProfileUI) {
        initialProfile = profile
        self.profile = profile
    }
    
}

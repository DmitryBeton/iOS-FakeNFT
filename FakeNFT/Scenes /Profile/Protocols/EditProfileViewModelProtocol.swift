protocol EditProfileViewModelProtocol: AnyObject {
    var onStateChange: ((EditProfileState) -> Void)? { get set }
    var onAvatarChange: (() -> Void)? { get set }
    
    var onChangesSaved: (() -> Void)? { get set }
    
    var profile: ProfileUI { get }
    var hasChanges: Bool { get }
    
    func loadProfile()
    func changeAvatar(urlString: String)
    func changeName(_ name: String)
    func changeDescription(_ description: String)
    func changeWebsite(urlString: String)
    func saveChanges()
}

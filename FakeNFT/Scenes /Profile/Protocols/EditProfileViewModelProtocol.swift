protocol EditProfileViewModelProtocol {
    var onStateChange: ((EditProfileState) -> Void)? { get set }
    var profile: ProfileUI { get }
    
    func loadProfile()
    func changeAvatar(urlString: String)
    func changeName(_ name: String)
    func changeDescription(_ description: String)
    func changeWebsite(urlString: String)
    func saveChanges()
}

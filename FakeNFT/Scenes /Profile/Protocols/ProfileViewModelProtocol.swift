protocol ProfileViewModelProtocol: AnyObject {
    var onStateChange: ((ProfileState) -> Void)? { get set }
    var service: ProfileServiceProtocol { get }
    
    func loadProfile()
    func getProfile() -> ProfileUI
    func myNFTCount() -> Int
    func favouritesCount() -> Int
}

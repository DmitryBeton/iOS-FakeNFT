protocol ProfileViewModelProtocol: AnyObject {
    var onStateChange: ((ProfileState) -> Void)? { get set }
    
    func loadProfile()
    func getProfile() -> ProfileUI
    func myNFTCount() -> Int
    func favouritesCount() -> Int
}

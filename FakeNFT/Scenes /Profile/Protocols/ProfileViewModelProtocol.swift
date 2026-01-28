protocol ProfileViewModelProtocol {
    var onStateChange: ((ProfileState) -> Void)? { get set }
    
    func loadProfile()
    func myNFTCount() -> Int
    func favouritesCount() -> Int
}

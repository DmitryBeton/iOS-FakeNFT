protocol ProfileViewModelProtocol {
    var onStateChange: ((ProfileState) -> Void)? { get set }
    func loadProfile()
}

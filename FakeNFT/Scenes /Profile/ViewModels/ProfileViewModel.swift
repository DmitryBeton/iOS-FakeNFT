import Foundation

final class ProfileViewModel: ProfileViewModelProtocol {
    
    // MARK: - Bindings
    
    var onStateChange: ((ProfileState) -> Void)?
    
    // MARK: - Public Methods
    
    // TODO: Should be changed with service implementation
    func loadProfile() {
        state = .loading
        let profileUI = makeProfileUI(from: mockProfile)
        state = .data(profileUI)
    }
    
    func myNFTCount() -> Int {
        mockProfile.nfts.count
    }
    
    func favouritesCount() -> Int {
        mockProfile.nfts.count
    }
    
    // MARK: - State
    
    private var state: ProfileState = .initial {
        didSet {
            onStateChange?(state)
        }
    }
    
    // MARK: - Private Properties
    
    // TODO: Should be replaced with data from service later
    private let mockProfile = Profile(
        id: UUID(),
        name: "Joaquin Phoenix",
        avatar: URL(string: "https://i.pinimg.com/736x/fc/e2/8b/fce28b5c4414c3492084022cb908f760.jpg"),
        description: """
            Дизайнер из Казани, люблю цифровое искусство
            и бейглы. В моей коллекции уже 100+ NFT,
            и еще больше — на моём сайте. Открыт
            к коллаборациям.
            """,
        website: URL(string: "https://practicum.yandex.ru/qa-automation-engineer-java/"),
        nfts: Array(repeating: UUID(), count: 11),
        likes: Array(repeating: UUID(), count: 6)
    )
    
    // MARK: - Private Methods
    
    private func makeProfileUI(from profile: Profile) -> ProfileUI {
        ProfileUI(
            name: profile.name,
            avatarURL: profile.avatar,
            description: profile.description,
            link: shortURLString(from: profile.website) ?? "",
        )
    }
    
    private func shortURLString(from url: URL?) -> String? {
        guard let url else { return nil }
        return url.host()?.replacingOccurrences(of: "www", with: "")
    }
    
}

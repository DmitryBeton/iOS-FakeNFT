import Foundation

final class ProfileViewModel: ProfileViewModelProtocol {
    
    // MARK: - Bindings
    
    var onStateChange: ((ProfileState) -> Void)?
    
    // MARK: - Public Properties
    
    private(set) var servicesAssembly: ServicesAssembly
    
    // MARK: - Public Methods
    
    func loadProfile() {
        state = .loading
        
        service.loadProfile() { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let profileResult):
                profile = profileResult
                let profileUI = mapToProfileUI(profileResult)
                state = .data(profileUI)
            case .failure(let error):
                state = .failed
                print("❌[ProfileService] failed to load data, error: \(error)")
            }
        }
    }
    
    func getProfile() -> ProfileUI {
        mapToProfileUI(profile)
    }
    
    func myNftCount() -> Int {
        profile?.nfts.count ?? 0
    }
    
    func favouritesCount() -> Int {
        profile?.likes.count ?? 0
    }
    
    func websiteURLString() -> String {
        profile?.website?.absoluteString ?? ""
    }
    
    // MARK: - State
    
    private var state: ProfileState = .initial {
        didSet {
            onStateChange?(state)
        }
    }
    
    // MARK: - Private Properties
    
    private let service: ProfileServiceProtocol
    private var profile: Profile?
    
    // MARK: - Init
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        self.service = servicesAssembly.profileService
    }
    
    // MARK: - Private Methods
    
    private func mapToProfileUI(_ profile: Profile?) -> ProfileUI {
        ProfileUI(
            name: profile?.name ?? "",
            avatarURL: profile?.avatar,
            description: profile?.description ?? "",
            link: profile?.website?.absoluteString ?? ""
        )
    }
    
}

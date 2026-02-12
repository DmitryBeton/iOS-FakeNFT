import Foundation

final class ProfileViewModel: ProfileViewModelProtocol {
    
    // MARK: - Bindings
    
    var onStateChange: ((ProfileState) -> Void)?
    
    // MARK: - Public Methods
    
    func loadProfile() {
        state = .loading
        
        service.loadProfile() { [weak self] result in
            if case let .failure(error) = result {
                self?.state = .failed
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
    private var profileObserver: NSObjectProtocol?
    
    // MARK: - Init
    
    init(profileService: ProfileServiceProtocol) {
        self.service = profileService
        observeProfileChanges()
    }
    
    // MARK: - Deinit
    
    deinit {
        if let profileObserver {
            NotificationCenter.default.removeObserver(profileObserver)
        }
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
    
    private func observeProfileChanges() {
        profileObserver = NotificationCenter.default.addObserver(
            forName: .profileDidChange,
            object: nil,
            queue: .main,
        ) { [weak self] notificaton in
            guard
                let self,
                let profile = notificaton.object as? Profile,
                self.profile != profile
            else { return }
            
            self.profile = profile
            let profileUI = self.mapToProfileUI(profile)
            self.state = .data(profileUI)
        }
    }
    
}


import Foundation

protocol UserCardViewModelProtocol: AnyObject {
    var onDataUpdated: (() -> Void)? { get set }
    var onLoadingChanged: ((Bool) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }

    var onOpenWebsite: ((URL) -> Void)? { get set }
    var onOpenCollection: ((String, Int) -> Void)? { get set }

    var model: UserCardModel? { get }

    func load(userId: String)
    func websiteTapped()
    func collectionTapped()
}

final class UserCardViewModel: UserCardViewModelProtocol {

    var onDataUpdated: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    var onOpenWebsite: ((URL) -> Void)?
    var onOpenCollection: ((String, Int) -> Void)?

    private let service: UserServiceProtocol
    private(set) var model: UserCardModel?

    private var userId: String?
    private var websiteURL: URL?
    private var nftCount: Int = 0

    init(service: UserServiceProtocol = UserService()) {
        self.service = service
    }

    func load(userId: String) {
        self.userId = userId
        onLoadingChanged?(true)

        service.fetchUser(id: userId) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let dto):
                let description = (dto.description?.isEmpty == false)
                    ? dto.description ?? "Нет описания"
                    : "Нет описания"
                self.model = UserCardModel(
                    avatarURLString: dto.avatar,
                    name: dto.name,
                    description: description,
                    website: dto.website,
                    nftCount: dto.nfts.count
                )
                self.websiteURL = URL(string: dto.website)
                self.nftCount = dto.nfts.count

                DispatchQueue.main.async {
                    self.onLoadingChanged?(false)
                    self.onDataUpdated?()
                }

            case .failure(let error):
                //AppLog.ui.error("UserCard load error: \(error.localizedDescription, privacy: .public)")
                DispatchQueue.main.async {
                    self.onLoadingChanged?(false)
                    self.onError?("Не удалось загрузить пользователя")
                }
            }
        }
    }

    func websiteTapped() {
        guard let url = websiteURL else {
            onError?("Некорректная ссылка")
            return
        }
        onOpenWebsite?(url)
    }

    func collectionTapped() {
        guard let userId else { return }
        onOpenCollection?(userId, nftCount)
    }
}


import Foundation

protocol MyNftViewModelProtocol {
    var onStateChange: ((MyNftState) -> Void)? { get set }
    var sortedNfts: [MyNftUI] { get }
}

final class MyNftViewModel: MyNftViewModelProtocol {
    
    // MARK: - Bindings
    
    var onStateChange: ((MyNftState) -> Void)?
    
    // MARK: - Public Properties
    
    var sortedNfts: [MyNftUI] {
        nfts.map {
            mapToUI($0)
        }
    }
    
    // MARK: - State
    
    private var state: MyNftState = .initial {
        didSet {
            onStateChange?(state)
        }
    }
    
    // MARK: - Private Properties
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    // TODO: - Should be replaced after service implementation
    // NOTE: Force unwrap is used only for test purposes
    private var nfts: [ProfileNft] = [
        ProfileNft(
            createdAt: Date(),
            name: "commodo porttitor",
            images: [
                URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")!,
                URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/2.png")!,
                URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/3.png")!
            ],
            rating: 3,
            description: "fringilla eam vim sonet faucibus impetus",
            price: 36.54,
            author: "Condescending Almeida",
            website: URL(string: "https://condescending_almeida.fakenfts.org/")!,
            id: UUID()
        ),
        ProfileNft(
            createdAt: Date(),
            name: "dico eleifend",
            images: [
                URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Helga/1.png")!,
                URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Helga/2.png")!,
                URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Helga/3.png")!,
            ],
            rating: 5,
            description: "tritani appareat constituam deterruisset justo",
            price: 8.08,
            author: "Quizzical Blackwell",
            website: URL(string: "https://quizzical_blackwell.fakenfts.org/")!,
            id: UUID()
        ),
        ProfileNft(
            createdAt: Date(),
            name: "eleifend mutat",
            images: [
                URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Kaydan/1.png")!,
                URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Kaydan/2.png")!,
                URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Gray/Kaydan/3.png")!,
            ],
            rating: 2,
            description: "tacimates docendi efficitur tempus non quod cras pellentesque commune",
            price: 16.95,
            author: "Goofy Napier",
            website: URL(string: "https://goofy_napier.fakenfts.org/")!,
            id: UUID()
        )
    ]
    
    // MARK: - Private Methods
    
    private func mapToUI(_ nft: ProfileNft) -> MyNftUI {
        MyNftUI(
            name: nft.name,
            image: nft.images[safe: 0],
            rating: nft.rating,
            price: priceFormatter.string(from: nft.price as NSDecimalNumber) ?? "",
            author: nft.author,
            id: nft.id,
            isLiked: true // TODO: implement logic for likes
        )
    }
    
}

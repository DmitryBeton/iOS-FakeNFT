import UIKit

struct StatisticsUserRowViewModel {
    let place: Int
    let name: String
    let nftCount: Int
    let avatarURLString: String

    init(user: StatisticsUserDomain, place: Int) {
        self.place = place
        self.name = user.name
        self.nftCount = user.nftCount
        self.avatarURLString = user.avatarURLString
    }

    func makeCellModel(avatarImage: UIImage? = nil) -> StatisticsUserCellModel {
        .init(
            place: place,
            name: name,
            nftCount: nftCount,
            avatarURL: avatarURLString,
            avatarImage: avatarImage
        )
    }
}


struct StatisticsUserRowViewModel {
    let place: Int
    let name: String
    let nftCountText: String
    let avatarURLString: String

    init(user: StatisticsUserDomain, place: Int) {
        self.place = place
        self.name = user.name
        self.nftCountText = "\(user.nftCount)"
        self.avatarURLString = user.avatarURLString
    }

    func makeCellModel() -> StatisticsUserCellModel {
        .init(
            place: place,
            name: name,
            nftCount: Int(nftCountText) ?? 0, 
            avatarURL: avatarURLString
        )
    }
}


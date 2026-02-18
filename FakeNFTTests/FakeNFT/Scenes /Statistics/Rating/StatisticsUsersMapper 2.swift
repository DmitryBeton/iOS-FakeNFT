import Foundation

struct StatisticsUsersMapper: StatisticsUsersMapperProtocol {
    func map(_ dto: [StatisticsUserDTO]) -> [StatisticsUserDomain] {
        dto.map {
            StatisticsUserDomain(
                name: $0.name,
                nftCount: $0.nfts.count,
                avatarURLString: $0.avatar
            )
        }
    }
}

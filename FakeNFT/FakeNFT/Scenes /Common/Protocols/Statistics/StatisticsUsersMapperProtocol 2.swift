protocol StatisticsUsersMapperProtocol {
    func map(_ dto: [StatisticsUserDTO]) -> [StatisticsUserDomain]
}

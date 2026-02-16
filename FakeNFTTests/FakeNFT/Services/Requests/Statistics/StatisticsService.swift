import Foundation

protocol StatisticsServiceProtocol {
    func fetchUsers(completion: @escaping (Result<[StatisticsUserDTO], Error>) -> Void)
}

final class StatisticsService: StatisticsServiceProtocol {

    private let client: NetworkClient

    init(client: NetworkClient = DefaultNetworkClient()) {
        self.client = client
    }

    func fetchUsers(completion: @escaping (Result<[StatisticsUserDTO], Error>) -> Void) {
        let request = UsersRequest()
        client.send(request: request, type: [StatisticsUserDTO].self, onResponse: completion)
    }
}


import Foundation

final class UserService: UserServiceProtocol {
    private let client: NetworkClient

    init(client: NetworkClient = DefaultNetworkClient()) {
        self.client = client
    }

    func fetchUsers(completion: @escaping (Result<[StatisticsUserDTO], Error>) -> Void) {
        let request = UsersRequest()
        client.send(request: request, type: [StatisticsUserDTO].self, onResponse: completion)
    }

    func fetchUser(id: String, completion: @escaping (Result<UserDetailDTO, Error>) -> Void) {
        let request = UserByIdRequest(id: id)
        client.send(request: request, type: UserDetailDTO.self, onResponse: completion)
    }
}


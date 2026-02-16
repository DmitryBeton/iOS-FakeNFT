import Foundation

protocol UserServiceProtocol {
    func fetchUser(id: String, completion: @escaping (Result<UserDetailDTO, Error>) -> Void)
}

final class UserService: UserServiceProtocol {

    private let client: NetworkClient

    init(client: NetworkClient = DefaultNetworkClient()) {
        self.client = client
    }

    func fetchUser(id: String, completion: @escaping (Result<UserDetailDTO, Error>) -> Void) {
        let request = UserByIdRequest(id: id)
        client.send(request: request, type: UserDetailDTO.self, onResponse: completion)
    }
}


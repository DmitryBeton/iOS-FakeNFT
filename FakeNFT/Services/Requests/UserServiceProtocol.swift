import Foundation

protocol UserServiceProtocol {
    func fetchUsers(completion: @escaping (Result<[StatisticsUserDTO], Error>) -> Void)
    func fetchUser(id: String, completion: @escaping (Result<UserDetailDTO, Error>) -> Void)
}


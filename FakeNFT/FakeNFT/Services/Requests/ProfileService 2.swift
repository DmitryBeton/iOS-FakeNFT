import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile(completion: @escaping (Result<ProfileDTO, Error>) -> Void)
    func updateProfile(dto: UpdateProfileDto, completion: @escaping (Result<ProfileDTO, Error>) -> Void)
}

final class ProfileService: ProfileServiceProtocol {

    private let client: NetworkClient

    init(client: NetworkClient = DefaultNetworkClient()) {
        self.client = client
    }

    func fetchProfile(completion: @escaping (Result<ProfileDTO, Error>) -> Void) {
        client.send(request: ProfileRequest(), type: ProfileDTO.self, onResponse: completion)
    }

    func updateProfile(dto: UpdateProfileDto, completion: @escaping (Result<ProfileDTO, Error>) -> Void) {
        client.send(request: UpdateProfileRequest(dto: dto), type: ProfileDTO.self, onResponse: completion)
    }
}


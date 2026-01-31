protocol ProfileServiceProtocol {
    func loadProfile(completion: @escaping ProfileCompletion)
    func updateProfile(with profileDto: ProfileDto, completion: @escaping ProfileCompletion)
}

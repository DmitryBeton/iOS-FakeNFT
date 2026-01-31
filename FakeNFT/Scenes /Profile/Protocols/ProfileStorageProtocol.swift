protocol ProfileStorageProtocol: AnyObject {
    func saveProfile(_ profile: Profile)
    func getProfile() -> Profile?
}

import Foundation

struct ProfileLikesDto: Dto {
    let likes: [UUID]
    
    private enum Keys: String {
        case likes
    }
    
    private let emptyValue = "null"
    
    func asDictionary() -> [String : String] {
        guard !likes.isEmpty else {
            return [Keys.likes.rawValue: emptyValue]
        }
        let idsString = likes.map { $0.uuidString.lowercased() }.joined(separator: ", ")
        return [Keys.likes.rawValue: idsString]
    }
}

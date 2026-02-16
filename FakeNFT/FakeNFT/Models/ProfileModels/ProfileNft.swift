import Foundation

struct ProfileNft: Decodable {
    let createdAt: Date
    let name: String
    let images: [URL]
    let rating: Int
    let description: String
    let price: Decimal
    let author: String
    let website: URL
    let id: UUID
    
    private enum CodingKeys: String, CodingKey {
        case createdAt, name, images, rating, description, price, author, website, id
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.images = try container.decode([URL].self, forKey: .images)
        self.rating = try container.decode(Int.self, forKey: .rating)
        self.description = try container.decode(String.self, forKey: .description)
        self.price = try container.decode(Decimal.self, forKey: .price)
        self.author = try container.decode(String.self, forKey: .author)
        self.website = try container.decode(URL.self, forKey: .website)
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let cleanedDateString = dateString.replacingOccurrences(of: "[GMT]", with: "")
    
        let formatter = DateFormatter.defaultDateFormatter
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: cleanedDateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        
        self.createdAt = date
    }
}

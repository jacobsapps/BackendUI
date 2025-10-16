import Foundation

struct ContentItem: Codable, Identifiable {
    let id: UUID
    let type: ContentType

    init(id: UUID = UUID(), type: ContentType) {
        self.id = id
        self.type = type
    }

    init(from decoder: Decoder) throws {
        self.id = UUID()
        self.type = try ContentType(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        try type.encode(to: encoder)
    }
}

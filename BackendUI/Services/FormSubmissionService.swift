import Foundation

enum FormSubmissionError: Error {
    case invalidURL
    case serverError(status: Int)
}

struct FormSubmissionService {
    static func diagnosticJSON(from values: [String: FormStore.Value]) -> String {
        struct Diagnostic: Encodable {
            let fields: [String: DiagnosticField]
        }
        enum DiagnosticField: Encodable {
            case text(String)
            case choice(String)
            case voiceBytes(Int)
            case photoBytes(Int)
            case location(latitude: Double, longitude: Double, name: String?)

            func encode(to encoder: Encoder) throws {
                var c = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case .text(let v):
                    try c.encode("text", forKey: .type)
                    try c.encode(v, forKey: .value)
                case .choice(let v):
                    try c.encode("choice", forKey: .type)
                    try c.encode(v, forKey: .value)
                case .voiceBytes(let n):
                    try c.encode("voice", forKey: .type)
                    try c.encode(n, forKey: .bytes)
                case .photoBytes(let n):
                    try c.encode("photo", forKey: .type)
                    try c.encode(n, forKey: .bytes)
                case .location(let lat, let lng, let name):
                    try c.encode("location", forKey: .type)
                    try c.encode(lat, forKey: .latitude)
                    try c.encode(lng, forKey: .longitude)
                    try c.encodeIfPresent(name, forKey: .name)
                }
            }

            enum CodingKeys: String, CodingKey {
                case type
                case value
                case bytes
                case latitude
                case longitude
                case name
            }
        }

        var dict: [String: DiagnosticField] = [:]
        for (key, value) in values {
            switch value {
            case .text(let s): dict[key] = .text(s)
            case .choice(let s): dict[key] = .choice(s)
            case .voice(let data): dict[key] = .voiceBytes(data.count)
            case .photo(let data): dict[key] = .photoBytes(data.count)
            case .location(let lat, let lng, let name): dict[key] = .location(latitude: lat, longitude: lng, name: name)
            }
        }
        let diagnostic = Diagnostic(fields: dict)
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? enc.encode(diagnostic), let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "{}"
    }
    
    static func submit(to endpoint: String, values: [String: FormStore.Value]) async throws {
        guard let url = URL(string: endpoint) else { throw FormSubmissionError.invalidURL }
        var builder = MultipartFormDataBuilder()

        for (key, value) in values {
            switch value {
            case .text(let s):
                builder.addText(name: key, value: s)
            case .choice(let s):
                builder.addText(name: key, value: s)
            case .voice(let data):
                builder.addFile(name: key, filename: "voice.m4a", mimeType: "audio/m4a", data: data)
            case .photo(let data):
                builder.addFile(name: key, filename: "photo.jpg", mimeType: "image/jpeg", data: data)
            case .location(let lat, let lng, let name):
                builder.addText(name: "\(key).lat", value: String(lat))
                builder.addText(name: "\(key).lng", value: String(lng))
                if let name { builder.addText(name: "\(key).name", value: name) }
            }
        }

        let (data, contentType) = builder.finalize()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (_, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw FormSubmissionError.serverError(status: http.statusCode)
        }
    }
}

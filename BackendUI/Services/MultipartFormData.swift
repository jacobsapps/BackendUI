import Foundation

struct MultipartFormDataBuilder {
    private let boundary: String
    private var body = Data()

    init(boundary: String = "Boundary-\(UUID().uuidString)") {
        self.boundary = boundary
    }

    mutating func addText(name: String, value: String) {
        let part = "--\(boundary)\r\n" +
        "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n" +
        "\(value)\r\n"
        body.append(part.data(using: .utf8)!)
    }

    mutating func addFile(name: String, filename: String, mimeType: String, data: Data) {
        var part = "--\(boundary)\r\n"
        part += "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n"
        part += "Content-Type: \(mimeType)\r\n\r\n"
        body.append(part.data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
    }

    func finalize() -> (data: Data, contentType: String) {
        var end = Data()
        end.append("--\(boundary)--\r\n".data(using: .utf8)!)
        var full = Data()
        full.append(body)
        full.append(end)
        return (full, "multipart/form-data; boundary=\(boundary)")
    }
}


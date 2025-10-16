import Foundation

/// Backend-driven content node rendered by the generic page renderer.
enum ContentType: Codable {
    case text(style: TextStyle, text: String, lineLimit: Int?)
    case link(text: String, url: String)
    case codeBlock(code: String, language: String)
    case image(url: String, caption: String?, width: Double?, height: Double?, cornerRadius: Double?)
    case quote(String)
    case divider(String)
    case stack(axis: AxisKey, spacing: Double?, children: [ContentItem])
    case navigationLink(label: [ContentItem], destination: ScreenContent)
    case videoPlayer(url: String, height: Double?)
    case textInput(label: String, placeholder: String?, key: String)
    case multipleChoice(question: String, options: [String], key: String)
    case voiceNote(label: String, key: String)
    case photoUpload(label: String, key: String)
    case mapLocation(label: String, initialRegion: MapRegion?, placemarks: [Placemark]?, key: String)
    case submitButton(label: String, endpoint: String)

    enum AxisKey: String, Codable { case h, v }
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case style
        case url
        case language
        case code
        case caption
        case axis
        case spacing
        case children
        case label
        case destination
        case width
        case height
        case cornerRadius
        case lineLimit
        case placeholder
        case key
        case options
        case question
        case initialRegion
        case placemarks
        case endpoint
    }
    
    enum TypeKey: String, Codable {
        case text
        case link
        case codeBlock
        case image
        case quote
        case divider
        case stack
        case navigationLink
        case videoPlayer
        case textInput
        case multipleChoice
        case voiceNote
        case photoUpload
        case mapLocation
        case submitButton
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            
        case .text(let style, let value, let lineLimit):
            try container.encode(TypeKey.text, forKey: .type)
            try container.encode(style, forKey: .style)
            try container.encode(value, forKey: .text)
            try container.encodeIfPresent(lineLimit, forKey: .lineLimit)
            
        case .link(let text, let url):
            try container.encode(TypeKey.link, forKey: .type)
            try container.encode(text, forKey: .text)
            try container.encode(url, forKey: .url)
            
        case .codeBlock(let code, let language):
            try container.encode(TypeKey.codeBlock, forKey: .type)
            try container.encode(code, forKey: .code)
            try container.encode(language, forKey: .language)
            
        case .image(let url, let caption, let width, let height, let cornerRadius):
            try container.encode(TypeKey.image, forKey: .type)
            try container.encode(url, forKey: .url)
            try container.encodeIfPresent(caption, forKey: .caption)
            try container.encodeIfPresent(width, forKey: .width)
            try container.encodeIfPresent(height, forKey: .height)
            try container.encodeIfPresent(cornerRadius, forKey: .cornerRadius)
            
        case .quote(let text):
            try container.encode(TypeKey.quote, forKey: .type)
            try container.encode(text, forKey: .text)
            
        case .divider(let text):
            try container.encode(TypeKey.divider, forKey: .type)
            try container.encode(text, forKey: .text)
        
        case .stack(let axis, let spacing, let children):
            try container.encode(TypeKey.stack, forKey: .type)
            try container.encode(axis, forKey: .axis)
            try container.encodeIfPresent(spacing, forKey: .spacing)
            try container.encode(children, forKey: .children)

        case .navigationLink(let label, let destination):
            try container.encode(TypeKey.navigationLink, forKey: .type)
            try container.encode(label, forKey: .label)
            try container.encode(destination, forKey: .destination)

        case .videoPlayer(let url, let height):
            try container.encode(TypeKey.videoPlayer, forKey: .type)
            try container.encode(url, forKey: .url)
            try container.encodeIfPresent(height, forKey: .height)

        case .textInput(let label, let placeholder, let key):
            try container.encode(TypeKey.textInput, forKey: .type)
            try container.encode(label, forKey: .label)
            try container.encodeIfPresent(placeholder, forKey: .placeholder)
            try container.encode(key, forKey: .key)

        case .multipleChoice(let question, let options, let key):
            try container.encode(TypeKey.multipleChoice, forKey: .type)
            try container.encode(question, forKey: .question)
            try container.encode(options, forKey: .options)
            try container.encode(key, forKey: .key)

        case .voiceNote(let label, let key):
            try container.encode(TypeKey.voiceNote, forKey: .type)
            try container.encode(label, forKey: .label)
            try container.encode(key, forKey: .key)

        case .photoUpload(let label, let key):
            try container.encode(TypeKey.photoUpload, forKey: .type)
            try container.encode(label, forKey: .label)
            try container.encode(key, forKey: .key)

        case .mapLocation(let label, let initialRegion, let placemarks, let key):
            try container.encode(TypeKey.mapLocation, forKey: .type)
            try container.encode(label, forKey: .label)
            try container.encodeIfPresent(initialRegion, forKey: .initialRegion)
            try container.encodeIfPresent(placemarks, forKey: .placemarks)
            try container.encode(key, forKey: .key)

        case .submitButton(let label, let endpoint):
            try container.encode(TypeKey.submitButton, forKey: .type)
            try container.encode(label, forKey: .label)
            try container.encode(endpoint, forKey: .endpoint)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(TypeKey.self, forKey: .type)
        
        switch type {
            
        case .link:
            let text = try container.decode(String.self, forKey: .text)
            let url = try container.decode(String.self, forKey: .url)
            self = .link(text: text, url: url)
            
        case .codeBlock:
            let code = try container.decode(String.self, forKey: .code)
            let language = try container.decode(String.self, forKey: .language)
            self = .codeBlock(code: code, language: language)
            
        case .image:
            let url = try container.decode(String.self, forKey: .url)
            let caption = try container.decodeIfPresent(String.self, forKey: .caption)
            let width = try container.decodeIfPresent(Double.self, forKey: .width)
            let height = try container.decodeIfPresent(Double.self, forKey: .height)
            let cornerRadius = try container.decodeIfPresent(Double.self, forKey: .cornerRadius)
            self = .image(url: url, caption: caption, width: width, height: height, cornerRadius: cornerRadius)
            
        case .quote:
            let text = try container.decode(String.self, forKey: .text)
            self = .quote(text)
            
        case .divider:
            let text = try container.decode(String.self, forKey: .text)
            self = .divider(text)
        
        case .text:
            let style = try container.decode(TextStyle.self, forKey: .style)
            let value = try container.decode(String.self, forKey: .text)
            let line = try container.decodeIfPresent(Int.self, forKey: .lineLimit)
            self = .text(style: style, text: value, lineLimit: line)

        case .stack:
            let axis = try container.decode(AxisKey.self, forKey: .axis)
            let spacing = try container.decodeIfPresent(Double.self, forKey: .spacing)
            let children = try container.decode([ContentItem].self, forKey: .children)
            self = .stack(axis: axis, spacing: spacing, children: children)

        case .navigationLink:
            let label = try container.decode([ContentItem].self, forKey: .label)
            let destination = try container.decode(ScreenContent.self, forKey: .destination)
            self = .navigationLink(label: label, destination: destination)

        case .videoPlayer:
            let url = try container.decode(String.self, forKey: .url)
            let height = try container.decodeIfPresent(Double.self, forKey: .height)
            self = .videoPlayer(url: url, height: height)
        
        case .textInput:
            let label = try container.decode(String.self, forKey: .label)
            let placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
            let key = try container.decode(String.self, forKey: .key)
            self = .textInput(label: label, placeholder: placeholder, key: key)

        case .multipleChoice:
            let question = try container.decode(String.self, forKey: .question)
            let options = try container.decode([String].self, forKey: .options)
            let key = try container.decode(String.self, forKey: .key)
            self = .multipleChoice(question: question, options: options, key: key)

        case .voiceNote:
            let label = try container.decode(String.self, forKey: .label)
            let key = try container.decode(String.self, forKey: .key)
            self = .voiceNote(label: label, key: key)

        case .photoUpload:
            let label = try container.decode(String.self, forKey: .label)
            let key = try container.decode(String.self, forKey: .key)
            self = .photoUpload(label: label, key: key)

        case .mapLocation:
            let label = try container.decode(String.self, forKey: .label)
            let initial = try container.decodeIfPresent(MapRegion.self, forKey: .initialRegion)
            let placemarks = try container.decodeIfPresent([Placemark].self, forKey: .placemarks)
            let key = try container.decode(String.self, forKey: .key)
            self = .mapLocation(label: label, initialRegion: initial, placemarks: placemarks, key: key)

        case .submitButton:
            let label = try container.decode(String.self, forKey: .label)
            let endpoint = try container.decode(String.self, forKey: .endpoint)
            self = .submitButton(label: label, endpoint: endpoint)
        }
    }
}

enum TextStyle: String, Codable {
    case title
    case subtitle
    case body
    case caption
}

// MARK: - Form helper models
struct MapRegion: Codable {
    let latitude: Double
    let longitude: Double
    let latitudeDelta: Double
    let longitudeDelta: Double
}

struct Placemark: Codable, Identifiable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
}

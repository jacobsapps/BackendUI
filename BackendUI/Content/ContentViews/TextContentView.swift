import SwiftUI

struct TextContentView: View {
    let style: TextStyle
    let text: String
    let lineLimit: Int?

    var body: some View {
        let attributed = (try? AttributedString(markdown: text)) ?? AttributedString(text)
        return Text(attributed)
            .font(font)
            .foregroundColor(color)
            .lineLimit(lineLimit)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var font: Font {
        switch style {
        case .title: return .headline.weight(.semibold)
        case .subtitle: return .subheadline.weight(.semibold)
        case .body: return .body
        case .caption: return .caption
        }
    }

    private var color: Color {
        switch style {
        case .caption: return .secondary
        default: return .primary
        }
    }
}

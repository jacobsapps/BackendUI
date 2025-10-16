import SwiftUI

struct ContentItemView: View {
    let item: ContentItem
    
    var body: some View {
        switch item.type {
        
        case .link(let text, let url):
            LinkContentView(text: text, url: url)
            
        case .codeBlock(let code, let language):
            CodeBlockContentView(code: code, language: language)
            
        case .image(let url, let caption, let width, let height, let cornerRadius):
            ImageContentView(url: url, caption: caption, width: width, height: height, cornerRadius: cornerRadius)
            
        case .quote(let text):
            QuoteContentView(text: text)
            
        case .divider(let text):
            DividerContentView(text: text)

        case .text(let style, let value, let lineLimit):
            TextContentView(style: style, text: value, lineLimit: lineLimit)

        case .stack(let axis, let spacing, let children):
            StackContentView(axis: axis, spacing: spacing, children: children)

        case .navigationLink(let label, let destination):
            NavigationLinkContentView(label: label, destination: destination)

        case .videoPlayer(let url, let height):
            VideoPlayerContentView(url: url, title: nil, description: nil, metadata: nil, height: height.map { CGFloat($0) })

        case .textInput(let label, let placeholder, let key):
            TextInputInputView(label: label, placeholder: placeholder, key: key)

        case .multipleChoice(let question, let options, let key):
            MultipleChoiceInputView(question: question, options: options, key: key)

        case .voiceNote(let label, let key):
            VoiceNoteInputView(label: label, key: key)

        case .photoUpload(let label, let key):
            PhotoUploadInputView(label: label, key: key)

        case .mapLocation(let label, let initialRegion, let placemarks, let key):
            MapLocationInputView(label: label, initialRegion: initialRegion, placemarks: placemarks ?? [], key: key)

        case .submitButton(let label, let endpoint):
            SubmitButtonInputView(label: label, endpoint: endpoint)
        }
    }
}

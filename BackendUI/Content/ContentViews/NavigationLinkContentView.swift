import SwiftUI

struct NavigationLinkContentView: View {
    let label: [ContentItem]
    let destination: ScreenContent

    var body: some View {
        NavigationLink {
            ContentRendererView(page: destination)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(label) { child in
                    ContentItemView(item: child)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI

struct ContentRendererView: View {
    let page: ScreenContent

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(Array(page.content.enumerated()), id: \.element.id) { _, item in
                    ContentItemView(item: item)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .navigationTitle(page.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}




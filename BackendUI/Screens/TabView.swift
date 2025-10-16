import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ContentScreen(endpoint: .swiftDataBlog)
                .tabItem {
                    Label("Blog", systemImage: "doc.text.image")
                }

            ContentScreen(endpoint: .videoPage)
                .tabItem {
                    Label("Videos", systemImage: "film")
                }

            ContentScreen(endpoint: .interactiveForm)
                .tabItem {
                    Label("Form", systemImage: "square.and.pencil")
                }
        }
    }
}

#Preview {
    ContentView()
}

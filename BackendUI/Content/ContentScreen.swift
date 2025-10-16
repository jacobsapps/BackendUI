import SwiftUI

struct ContentScreen: View {
    let endpoint: MockAPI.Endpoint
    
    @State private var page: ScreenContent?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @StateObject private var formStore = FormStore()

    var body: some View {
        NavigationStack {
            Group {
                if let page {
                    ContentRendererView(page: page)
                        .environmentObject(formStore)
                } else if isLoading {
                    ProgressView().padding()
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle").font(.system(size: 40)).foregroundStyle(.secondary)
                        Text(errorMessage).multilineTextAlignment(.center).foregroundStyle(.secondary)
                        Button("Retry", action: load)
                    }
                    .padding()
                } else {
                    Color.clear.onAppear(perform: load)
                }
            }
        }
    }

    private func load() {
        isLoading = true
        errorMessage = nil
        do {
            page = try MockAPI.fetchPageContent(endpoint)
        } catch {
            errorMessage = "Failed to load page."
        }
        isLoading = false
    }
}

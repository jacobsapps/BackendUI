import SwiftUI
import AVKit

struct VideoPlayerContentView: View {
    let url: String
    let title: String?
    let description: String?
    let metadata: String?
    let height: CGFloat?

    @State private var player: AVPlayer?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: height ?? 220)
                    .cornerRadius(12)
            } else {
                Color.black.frame(height: height ?? 220).cornerRadius(12)
            }

            if let title { Text(title).font(.title3).bold() }
            if let metadata { Text(metadata).font(.subheadline).foregroundStyle(.secondary) }
            if let description, !description.isEmpty { Text(description).font(.body) }
        }
        .onAppear {
            if let u = URL(string: url) { player = AVPlayer(url: u) }
        }
        .onDisappear { player?.pause() }
    }
}

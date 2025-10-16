import SwiftUI

struct EqualizerView: View {
    let levels: [CGFloat]
    let playbackProgress: CGFloat?
    let barColor: Color

    init(levels: [CGFloat], playbackProgress: CGFloat? = nil, barColor: Color = .blue) {
        self.levels = levels
        self.playbackProgress = playbackProgress
        self.barColor = barColor
    }

    private let barWidth: CGFloat = 2
    private let barSpacing: CGFloat = 1
    private let minHeight: CGFloat = 2
    private let greyColor = Color.gray.opacity(0.3)

    var body: some View {
        GeometryReader { geo in
            let maxBars = max(1, Int((geo.size.width + barSpacing) / (barWidth + barSpacing)))
            let down = downsample(levels: levels, to: maxBars)
            let totalWidth = CGFloat(down.count) * (barWidth + barSpacing) - barSpacing
            let startX = max(0, (geo.size.width - totalWidth) / 2)
            let progressCount = playbackProgress.map { Int(CGFloat(down.count) * max(0, min(1, $0))) } ?? down.count

            ZStack(alignment: .leading) {
                HStack(spacing: barSpacing) {
                    ForEach(down.indices, id: \.self) { idx in
                        let value = max(0, min(1, down[idx]))
                        let height = max(minHeight, geo.size.height * value)
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            RoundedRectangle(cornerRadius: barWidth/2)
                                .fill(idx < progressCount ? barColor : greyColor)
                                .frame(width: barWidth, height: height)
                            Spacer(minLength: 0)
                        }
                        .animation(.easeOut(duration: 0.08), value: value)
                    }
                }
                .frame(width: totalWidth, alignment: .leading)
                .offset(x: startX)
            }
        }
        .frame(height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .background(
            Color.black.opacity(0.5)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        )
    }


    private func downsample(levels: [CGFloat], to target: Int) -> [CGFloat] {
        guard target > 0 else { return [] }
        if levels.count <= target { return levels }
        let chunk = max(1, levels.count / target)
        var out: [CGFloat] = []
        out.reserveCapacity(target)
        var i = 0
        while i < levels.count && out.count < target {
            let end = min(i + chunk, levels.count)
            let slice = levels[i..<end]
            let avg = slice.reduce(0, +) / CGFloat(slice.count)
            out.append(avg)
            i += chunk
        }
        return out
    }
}

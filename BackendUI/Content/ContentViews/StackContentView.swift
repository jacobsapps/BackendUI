import SwiftUI

struct StackContentView: View {
    let axis: ContentType.AxisKey
    let spacing: Double?
    let children: [ContentItem]

    var body: some View {
        if axis == .v {
            VStack(alignment: .leading, spacing: spacing.map { CGFloat($0) } ?? 8) {
                ForEach(children) { child in
                    ContentItemView(item: child)
                }
            }
        } else {
            HStack(alignment: .top, spacing: spacing.map { CGFloat($0) } ?? 8) {
                ForEach(children) { child in
                    ContentItemView(item: child)
                }
            }
        }
    }
}


import SwiftUI

struct ImageContentView: View {
    let url: String
    let caption: String?
    let width: CGFloat?
    let height: CGFloat?
    let cornerRadius: CGFloat?
    
    init(url: String, caption: String?, width: Double? = nil, height: Double? = nil, cornerRadius: Double? = nil) {
        self.url = url
        self.caption = caption
        self.width = width.map { CGFloat($0) }
        self.height = height.map { CGFloat($0) }
        self.cornerRadius = cornerRadius.map { CGFloat($0) }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: width ?? .infinity)
                            .frame(height: height ?? 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: (width != nil || height != nil) ? .fill : .fit)
                            .frame(width: width, height: height, alignment: .center)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .frame(maxWidth: width ?? .infinity)
                            .frame(height: height ?? 200)
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(cornerRadius ?? 8)
            }
            
            if let caption = caption {
                Text(caption)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
                    .italic()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
        }
    }
}

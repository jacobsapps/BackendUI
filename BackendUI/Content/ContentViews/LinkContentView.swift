import SwiftUI

struct LinkContentView: View {
    let text: String
    let url: String
    
    var body: some View {
        Button(action: {
            guard let url = URL(string: url) else { return }
            UIApplication.shared.open(url)
        }, label: {
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .underline()
                .foregroundColor(.blue)
                .multilineTextAlignment(.leading)
                .contentShape(Rectangle())
        })
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

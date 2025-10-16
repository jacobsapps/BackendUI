import SwiftUI

struct DividerContentView: View {
    let text: String
    
    var body: some View {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            SwiftUI.Divider()
                .padding(.vertical, 6)
        } else {
            Text(text)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 12)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

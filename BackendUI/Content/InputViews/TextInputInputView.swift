import SwiftUI

struct TextInputInputView: View {
    @EnvironmentObject private var store: FormStore
    let label: String
    let placeholder: String?
    let key: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.subheadline).padding(.top, 12)
            TextField(placeholder ?? "", text: store.text(key))
                .textFieldStyle(.roundedBorder)
        }
        .padding(.vertical, 6)
    }
}

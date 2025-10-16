import SwiftUI

struct MultipleChoiceInputView: View {
    @EnvironmentObject private var store: FormStore
    let question: String
    let options: [String]
    let key: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question).font(.subheadline).padding(.top, 12)
            ForEach(options, id: \.self) { option in
                HStack {
                    let selected = isSelected(option)
                    Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                        .foregroundStyle(selected ? .primary : .secondary)
                    Text(option)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { select(option) }
            }
        }
        .padding(.vertical, 6)
    }

    private func isSelected(_ option: String) -> Bool {
        if case let .choice(v)? = store.values[key] { return v == option }
        return false
    }
    private func select(_ option: String) { store.set(key, value: .choice(option)) }
}

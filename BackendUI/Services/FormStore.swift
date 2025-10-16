import Foundation
import SwiftUI
import Combine

final class FormStore: ObservableObject {
    enum Value {
        case text(String)
        case choice(String)
        case voice(Data)
        case photo(Data)
        case location(latitude: Double, longitude: Double, name: String?)
    }

    @Published var values: [String: Value] = [:]
    @Published var isSubmitting: Bool = false
    @Published var submitError: String?
    @Published var submitSuccess: Bool = false

    func set(_ key: String, value: Value) {
        values[key] = value
    }

    func text(_ key: String) -> Binding<String> {
        Binding<String>(
            get: {
                if case let .text(v)? = self.values[key] { return v }
                return ""
            },
            set: { self.values[key] = .text($0) }
        )
    }
}

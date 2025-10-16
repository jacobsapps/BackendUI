import SwiftUI

import UIKit

struct SubmitButtonInputView: View {
    @EnvironmentObject private var store: FormStore
    let label: String
    let endpoint: String

    var body: some View {
        VStack(alignment: .center) {
            Button(action: submit) {
                ZStack {
                    LinearGradient(colors: [.purple, .pink, .orange], startPoint: .leading, endPoint: .trailing)
                        .frame(height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    if store.isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text(label).bold().foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            if let err = store.submitError { Text(err).foregroundStyle(.red).font(.footnote) }
            if store.submitSuccess { Text("Submitted!").foregroundStyle(.green).font(.footnote) }
        }
        .padding(.vertical, 10)
    }

    private func submit() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        store.isSubmitting = true
        store.submitError = nil
        store.submitSuccess = false
        Task {
            do {
                #if DEBUG
                let diagnostic = FormSubmissionService.diagnosticJSON(from: store.values)
                print("Submitting feedback form:\n\(diagnostic)")
                #endif
                try await Task.sleep(nanoseconds: 1_000_000_000)
                if let host = URL(string: endpoint)?.host, host.contains("example.com") {
                } else {
                    try await FormSubmissionService.submit(to: endpoint, values: store.values)
                }
                await MainActor.run { store.submitSuccess = true }
            } catch {
                await MainActor.run { store.submitError = "Submit failed" }
            }
            await MainActor.run { store.isSubmitting = false }
        }
    }
}

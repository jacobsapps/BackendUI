import SwiftUI
import PhotosUI

struct PhotoUploadInputView: View {
    @EnvironmentObject private var store: FormStore
    @State private var item: PhotosPickerItem?
    @State private var image: Image?
    @State private var showCamera = false
    let label: String
    let key: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.subheadline)
            if let image {
                image.resizable().scaledToFill().frame(width: 200, height: 120).clipped().cornerRadius(12)
            }
            HStack(spacing: 12) {
                PhotosPicker(selection: $item, matching: .images, photoLibrary: .shared()) {
                    Label(image == nil ? "Pick Photo" : "Change Photo", systemImage: "photo")
                }
                Spacer()
                Button {
                    showCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                }
            }
        }
        .onChange(of: item) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    store.set(key, value: .photo(data))
                    if let ui = UIImage(data: data) { image = Image(uiImage: ui) }
                }
            }
        }
        .padding(.vertical, 6)
        .sheet(isPresented: $showCamera) {
            CameraPicker { ui in
                let data = ui.jpegData(compressionQuality: 0.9) ?? Data()
                store.set(key, value: .photo(data))
                image = Image(uiImage: ui)
            }
        }
    }
}

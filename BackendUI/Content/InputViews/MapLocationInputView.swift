import SwiftUI
import MapKit

struct MapLocationInputView: View {
    @EnvironmentObject private var store: FormStore
    let label: String
    let initialRegion: MapRegion?
    let placemarks: [Placemark]
    let key: String

    @State private var region: MKCoordinateRegion = .init()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selection: Placemark?
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var showLookAroundExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.subheadline).padding(.top, 12)
            Text("Tap the map to select it.").font(.caption).foregroundStyle(.secondary)
            Group {
                if #available(iOS 17.0, *) {
                    MapReader { proxy in
                        Map(position: $cameraPosition) {
                            if let selection {
                                Annotation("Selected", coordinate: CLLocationCoordinate2D(latitude: selection.latitude, longitude: selection.longitude)) {
                                    ZStack {
                                        Circle().fill(.blue).frame(width: 16, height: 16)
                                        Circle().stroke(.white, lineWidth: 2).frame(width: 16, height: 16)
                                    }
                                }
                            }
                        }
                        // Treat only short drags (taps) as selection; allow pan/zoom to pass through
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    let start = value.startLocation
                                    let end = value.location
                                    let dx = end.x - start.x
                                    let dy = end.y - start.y
                                    if (dx*dx + dy*dy) < 100 { // within ~10pt radius = tap
                                        if let coord = proxy.convert(end, from: .local) {
                                            selection = Placemark(id: UUID().uuidString, name: "", latitude: coord.latitude, longitude: coord.longitude)
                                            store.set(key, value: .location(latitude: coord.latitude, longitude: coord.longitude, name: nil))
                                            let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            let span = (region.span.latitudeDelta == 0 && region.span.longitudeDelta == 0) ? defaultSpan : region.span
                                            cameraPosition = .region(MKCoordinateRegion(center: coord, span: span))
                                            Task { await fetchLookAround(for: coord) }
                                        }
                                    }
                                }
                        )
                        .overlay(alignment: .bottomTrailing) {
                            if let _ = lookAroundScene {
                                LookAroundPreview(scene: $lookAroundScene, allowsNavigation: true, badgePosition: .bottomTrailing)
                                    .frame(width: 140, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .shadow(radius: 6)
                                    .padding()
                                    .onTapGesture { showLookAroundExpanded = true }
                            }
                        }
                    }
                } else {
                    Map(coordinateRegion: $region, annotationItems: placemarks) { place in
                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
                    }
                }
            }
            .frame(height: 220)
            .cornerRadius(10)
            .sheet(isPresented: $showLookAroundExpanded) {
                if #available(iOS 17.0, *) {
                    LookAroundPreview(scene: $lookAroundScene, allowsNavigation: true, badgePosition: .bottomTrailing)
                        .ignoresSafeArea()
                } else {
                    Text("Look Around requires iOS 17+")
                        .padding()
                }
            }
        }
        .onAppear {
            if let r = initialRegion {
                region = .init(center: CLLocationCoordinate2D(latitude: r.latitude, longitude: r.longitude), span: .init(latitudeDelta: r.latitudeDelta, longitudeDelta: r.longitudeDelta))
                if #available(iOS 17.0, *) { cameraPosition = .region(region) }
            } else if let first = placemarks.first {
                region = .init(center: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude), span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05))
                selection = first
                store.set(key, value: .location(latitude: first.latitude, longitude: first.longitude, name: first.name))
                Task { await fetchLookAround(for: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude)) }
                if #available(iOS 17.0, *) { cameraPosition = .region(region) }
            }
        }
        .padding(.vertical, 6)
        .overlay(Divider(), alignment: .bottom)
    }

    @available(iOS 17.0, *)
    private func fetchLookAround(for coord: CLLocationCoordinate2D) async {
        let request = MKLookAroundSceneRequest(coordinate: coord)
        let scene = try? await request.scene
        await MainActor.run { self.lookAroundScene = scene }
    }
}

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {
            PhotoGalleryView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Gallery")
                }
                .tag(0)

            CameraView()
                .tabItem {
                    Image(systemName: "camera")
                    Text("Camera")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.white) // Tab bar tint color
    }
}

struct PhotoGalleryView: View {
    var body: some View {
        Text("Photo Gallery")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

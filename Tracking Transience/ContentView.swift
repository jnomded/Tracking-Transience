//
//  ContentView.swift
//  Tracking Transience
//
//  Created by James Edmond on 8/26/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        VStack {
            Text("Current Location:")
                .font(.headline)
            if let location = trackingManager.currentLocation {
                Text("Latitude: \(location.coordinate.latitude)")
                Text("Longitude: \(location.coordinate.longitude)")
            } else {
                Text("Location not available")
            }
            
            Divider()
            
            Text("Last Photo:")
                .font(.headline)
            if let photo = trackingManager.lastPhoto {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            } else {
                Text("No photo available")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

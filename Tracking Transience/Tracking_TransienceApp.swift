//
//  Tracking_TransienceApp.swift
//  Tracking Transience
//
//  Created by James Edmond on 8/26/24.
//
import SwiftUI
import SwiftData

@main
struct Tracking_TransienceApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: Photo.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}



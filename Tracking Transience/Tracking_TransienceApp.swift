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
    var body: some Scene {
        WindowGroup {
            RotationHandlingViewControllerWrapper()
        }
    }
}

struct RotationHandlingViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return RotationHandlingViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

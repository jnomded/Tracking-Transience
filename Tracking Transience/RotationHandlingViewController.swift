//
//  RotationHandlingViewController.swift
//  Tracking Transience
//
//  Created by James Edmond on 9/3/24.
//


import UIKit
import SwiftUI

class RotationHandlingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let hostingController = UIHostingController(rootView: ContentView())
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.didMove(toParent: self)

        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc private func handleOrientationChange() {
        // Force layout update or any other adjustments needed
        view.setNeedsLayout()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Update the layout of the child views if needed
        if let hostingController = children.first as? UIHostingController<ContentView> {
            hostingController.view.frame = view.bounds
        }
    }
}

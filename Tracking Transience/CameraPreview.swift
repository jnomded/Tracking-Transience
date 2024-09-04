//
//  CameraPreview.swift
//  Tracking Transience
//
//  Created by James Edmond on 9/3/24.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    @Binding var image: UIImage?
    @Binding var isFlashOn: Bool
    @Binding var isUsingFrontCamera: Bool

    private let session = AVCaptureSession()
    private var currentCameraPosition: AVCaptureDevice.Position = .back

    // Public initializer
    init(image: Binding<UIImage?>, isFlashOn: Binding<Bool>, isUsingFrontCamera: Binding<Bool>) {
        self._image = image
        self._isFlashOn = isFlashOn
        self._isUsingFrontCamera = isUsingFrontCamera
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        setupCamera()

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        updateFlashMode()
        if isUsingFrontCamera != (currentCameraPosition == .front) {
            context.coordinator.switchCamera()
        }
    }

    private func setupCamera() {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
    }

    private func updateFlashMode() {
        guard let output = session.outputs.first as? AVCapturePhotoOutput else { return }
        let flashMode: AVCaptureDevice.FlashMode = isFlashOn ? .on : .off
        if let photoSettings = output.photoSettingsForSceneMonitoring {
            photoSettings.flashMode = flashMode
        }
    }

    class Coordinator: NSObject {
        var parent: CameraPreviewView

        init(_ parent: CameraPreviewView) {
            self.parent = parent
        }

        func switchCamera() {
            parent.session.beginConfiguration()
            defer { parent.session.commitConfiguration() }

            parent.session.inputs.forEach { input in
                parent.session.removeInput(input)
            }

            parent.currentCameraPosition = parent.currentCameraPosition == .back ? .front : .back
            parent.setupCamera()
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        uiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
}

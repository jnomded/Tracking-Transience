import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    @Binding var isFlashOn: Bool
    @Binding var isUsingFrontCamera: Bool

    private let session = AVCaptureSession()
    private var currentCameraPosition: AVCaptureDevice.Position = .back

    // Public initializer
    init(isFlashOn: Binding<Bool>, isUsingFrontCamera: Binding<Bool>) {
        self._isFlashOn = isFlashOn
        self._isUsingFrontCamera = isUsingFrontCamera
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        let previewLayer = AVCaptureVideoPreviewLayer(session:
 session)
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
        // Check if the current camera position matches the desired camera position
        if isUsingFrontCamera != (currentCameraPosition == .front) {
            // If not, switch the camera
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

            // Update the current camera position before setting up the new camera
            parent.currentCameraPosition = parent.currentCameraPosition == .back ? .front : .back
            parent.setupCamera()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.parent.session.stopRunning()
    }
}

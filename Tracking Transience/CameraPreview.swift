import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    @Binding var isFlashOn: Bool
    @Binding var isUsingFrontCamera: Bool

    private let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var currentCameraPosition: AVCaptureDevice.Position = .back

    init(isFlashOn: Binding<Bool>, isUsingFrontCamera: Binding<Bool>) {
        self._isFlashOn = isFlashOn
        self._isUsingFrontCamera = isUsingFrontCamera
        setupCamera()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        // Assign coordinator properties
        context.coordinator.session = session
        context.coordinator.photoOutput = photoOutput

        // Start the session after setup is complete
        startCaptureSession()

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if isUsingFrontCamera != (currentCameraPosition == .front) {
            context.coordinator.switchCamera()
        }
    }

    private func setupCamera() {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        // Remove existing inputs and outputs
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }

        // Configure camera input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else {
            print("Failed to get camera device")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                print("Failed to add camera input")
                return
            }
        } catch {
            print("Failed to create camera input: \(error)")
            return
        }

        // Configure photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        } else {
            print("Failed to add photo output")
            return
        }
    }

    private func startCaptureSession() {
        DispatchQueue.main.async {
            if !self.session.isRunning {
                self.session.startRunning()
                print("Capture session started")
            } else {
                print("Capture session was already running")
            }
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.main.async {
            if !self.session.isRunning {
                print("Capture session is not running, attempting to start...")
                self.startCaptureSession()
                // Wait a bit for the session to start
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.capturePhotoInternal(completion: completion)
                }
            } else {
                self.capturePhotoInternal(completion: completion)
            }
        }
    }

    private func capturePhotoInternal(completion: @escaping (UIImage?) -> Void) {
        guard self.session.isRunning else {
            print("Failed to start capture session")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.isFlashOn ? .on : .off

        self.photoOutput.capturePhoto(with: settings, delegate: self.makeCoordinator().photoCaptureDelegate(completion: completion))
    }

    class Coordinator: NSObject {
        var session: AVCaptureSession?
        var photoOutput: AVCapturePhotoOutput?

        func switchCamera() {
            guard let session = session else { return }

            session.beginConfiguration()
            defer { session.commitConfiguration() }

            session.inputs.forEach { session.removeInput($0) }
            // Switching logic here (similar to the previous implementation)
            // Make sure to re-setup camera
        }

        func photoCaptureDelegate(completion: @escaping (UIImage?) -> Void) -> AVCapturePhotoCaptureDelegate {
            return PhotoCaptureDelegate(completion: completion)
        }

        class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
            private let completion: (UIImage?) -> Void

            init(completion: @escaping (UIImage?) -> Void) {
                self.completion = completion
            }

            func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
                if let error = error {
                    print("Error capturing photo: \(error)")
                    completion(nil)
                    return
                }

                guard let imageData = photo.fileDataRepresentation() else {
                    print("No image data found")
                    completion(nil)
                    return
                }

                let image = UIImage(data: imageData)
                print("Photo data processed")
                completion(image)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.session?.stopRunning()
    }
}

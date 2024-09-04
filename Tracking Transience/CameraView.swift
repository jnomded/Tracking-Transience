import SwiftUI
import AVFoundation

struct CameraView: View {
    @State private var image: UIImage?
    @State private var isFlashOn = false
    @State private var isUsingFrontCamera = false

    var body: some View {
        ZStack {
            CameraPreviewView(image: $image, isFlashOn: $isFlashOn, isUsingFrontCamera: $isUsingFrontCamera)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isFlashOn.toggle()
                    }) {
                        Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 20)

                    Button(action: {
                        isUsingFrontCamera.toggle()
                    }) {
                        Image(systemName: "camera.rotate.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 50)

                Spacer()

                Button(action: {
                    // Implement capture functionality here
                    capturePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.8), lineWidth: 4)
                                .frame(width: 90, height: 90)
                        )
                        .shadow(radius: 10)
                }
                .padding(.bottom, 30)
            }

            // Cropping overlay to match the 750x1000 aspect ratio
            Rectangle()
                .stroke(Color.white, lineWidth: 2)
                .aspectRatio(750.0/1000.0, contentMode: .fit)
                .padding(EdgeInsets(top: 50, leading: 20, bottom: 120, trailing: 20))
                .allowsHitTesting(false)
        }
    }

    private func capturePhoto() {
        // Call the capture photo method from CameraPreviewView
        // You need to provide a way to trigger this method
    }
}


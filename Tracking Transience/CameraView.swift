import SwiftUI
import SwiftData
import AVFoundation

struct CameraView: View {
    @State private var image: UIImage?
    @State private var isFlashOn = false
    @State private var isUsingFrontCamera = false
    @State private var isLandscape = UIDevice.current.orientation.isLandscape

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreviewView(isFlashOn: $isFlashOn, isUsingFrontCamera: $isUsingFrontCamera)
                    .edgesIgnoringSafeArea(.all)
                    .onRotate { newOrientation in
                        withAnimation(.easeInOut) {
                            isLandscape = newOrientation.isLandscape
                        }
                    }

                VStack {
                    Spacer()
                    
                    if isLandscape {
                        HStack {
                            // Flash Button
                            Button(action: {
                                isFlashOn.toggle()
                            }) {
                                Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(-90))
                            }
                            .padding(.leading, 28) // Reduced padding

                            Spacer()
                            
                            // Capture Button
                            Button(action: {
                                capturePhoto()
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black.opacity(0.8), lineWidth: 4)
                                            .frame(width: 65, height: 65)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(1.0), lineWidth: 3.5)
                                                    .frame(width: 68, height: 68)
                                            )
                                    )
                                    .shadow(radius: 10)
                            }
                            
                            Spacer()
                            
                            // Switch Camera Button
                            Button(action: {
                                isUsingFrontCamera.toggle()
                            }) {
                                Image(systemName: "camera.rotate.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(isLandscape ? (UIDevice.current.orientation == .landscapeLeft ? 90 : -90) : 0))
                            }
                            .padding(.trailing, 16) // Reduced padding
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom - 16) // Reduced bottom padding
                    } else {
                        HStack {
                            // Flash Button
                            Button(action: {
                                isFlashOn.toggle()
                            }) {
                                Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            .padding(.leading, 28) // Reduced padding
                            .padding(.bottom, geometry.safeAreaInsets.bottom - 16) // Reduced bottom padding

                            Spacer()

                            // Capture Button
                            Button(action: {
                                capturePhoto()
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black.opacity(0.8), lineWidth: 4)
                                            .frame(width: 65, height: 65)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(1.0), lineWidth: 3.5)
                                                    .frame(width: 68, height: 68)
                                            )
                                    )
                                    .shadow(radius: 10)
                            }
                            .padding(.bottom, geometry.safeAreaInsets.bottom - 16) // Reduced bottom padding

                            Spacer()

                            // Switch Camera Button
                            Button(action: {
                                isUsingFrontCamera.toggle()
                            }) {
                                Image(systemName: "camera.rotate.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 16) // Reduced padding
                            .padding(.bottom, geometry.safeAreaInsets.bottom - 16) // Reduced bottom padding
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                
                // Cropping overlay to match the 3:2 aspect ratio and adjust size for landscape
                Rectangle()
                    .stroke(Color.white, lineWidth: 2)
                    .aspectRatio(3.0/2.0, contentMode: .fit)
                    .frame(
                        width: isLandscape ? geometry.size.width * 1.25 : geometry.size.width * 0.9,
                        height: isLandscape ? (geometry.size.width * 1.25 * (2.0/3.0)) : (geometry.size.width * 0.9 * (2.0/3.0))
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .rotationEffect(.degrees(isLandscape ? 90 : 0))
                    .animation(.easeInOut, value: isLandscape)
            }
        }
    }

    private func capturePhoto() {
        // Call the capture photo method from CameraPreviewView
        // You need to provide a way to trigger this method
    }
}

// A custom ViewModifier to detect orientation changes
struct RotateModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(RotateModifier(action: action))
    }
}

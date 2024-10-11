//
//  ContentView.swift
//  Tracking Transience
//
//  Created by James Edmond on 8/26/24.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct ContentView: View {
    @State private var personalCode = ""
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var processedImages: [ProcessedImage] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Surveillance Photo Sharing")
                .font(.largeTitle)
            
            Button("Generate Personal Code") {
                generatePersonalCode()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Text("Your personal code: \(personalCode)")
                .font(.headline)
            
            PhotosPicker(selection: $selectedItems, matching: .images) {
                Text("Select Photos")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            // This is for whenever the selected items array changes
            .onChange(of: selectedItems) { _ in
                Task {
                    await processSelectedPhotos()
                }
            }
            
            // Only show the upload button if we actually have something to upload
            if !processedImages.isEmpty {
                Button("Upload Photos") {
                    uploadPhotos()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Simple progress view
            if isUploading {
                ProgressView("Uploading...")
            }
            
            // Display processed images
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(processedImages.indices, id: \.self) { index in
                        Image(uiImage: processedImages[index].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 75)
                            .clipped()
                    }
                }
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Message"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Just making an 8-char code
    func generatePersonalCode() {
        personalCode = UUID().uuidString.prefix(8).uppercased()
    }
    
    // Converts selected images into resized versions and grabs metadata
    func processSelectedPhotos() async {
        processedImages.removeAll()
        
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                if let resized = resizeImage(uiImage, width: 400, height: 300) {
                    let metadata = await getImageMetadata(from: item)
                    let newImage = ProcessedImage(image: resized, metadata: metadata)
                    processedImages.append(newImage)
                }
            }
        }
    }
    
    // Basic resizing to a 4:3 ratio
    func resizeImage(_ input: UIImage, width: CGFloat, height: CGFloat) -> UIImage? {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        input.draw(in: CGRect(origin: .zero, size: size))
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
    
    // Grab the creation date and location from the photo (if available)
    func getImageMetadata(from item: PhotosPickerItem) async -> ImageMetadata {
        var dateTime: Date?
        var location: CLLocationCoordinate2D?
        
        if let itemID = item.itemIdentifier {
            let result = PHAsset.fetchAssets(withLocalIdentifiers: [itemID], options: nil)
            if let asset = result.firstObject {
                dateTime = asset.creationDate
                if let assetLocation = asset.location {
                    location = assetLocation.coordinate
                }
            }
        }
        
        return ImageMetadata(dateTime: dateTime, location: location)
    }
    
    // Does a multipart upload of images & metadata
    func uploadPhotos() {
        guard !personalCode.isEmpty else {
            alertMessage = "Please generate a personal code first."
            showAlert = true
            return
        }
        
        isUploading = true
        
        // this is mine.. please replace with your own
        guard let url = URL(string: "http://192.168.1.147:3000/upload") else {
            alertMessage = "Invalid server URL"
            showAlert = true
            isUploading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add the personal code
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"personalCode\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(personalCode)\r\n".data(using: .utf8)!)
        
        // Add each image + metadata
        for (index, pImage) in processedImages.enumerated() {
            if let imageData = pImage.image.jpegData(compressionQuality: 0.8) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"photos\"; filename=\"photo\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
                
                // Stuffing metadata in a separate field
                let metaString = pImage.metadata.toString()
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"metadata\(index)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(metaString)\r\n".data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // start the upload
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isUploading = false
                
                if let err = error {
                    alertMessage = "Upload failed: \(err.localizedDescription)"
                } else if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                    alertMessage = "Photos uploaded successfully!"
                    processedImages.removeAll()
                    selectedItems.removeAll()
                } else {
                    alertMessage = "Upload failed with an unknown error."
                }
                
                showAlert = true
            }
        }.resume()
    }
}

struct ProcessedImage {
    let image: UIImage
    let metadata: ImageMetadata
}

struct ImageMetadata {
    let dateTime: Date?
    let location: CLLocationCoordinate2D?
    
    func toString() -> String {
        var parts: [String] = []
        
        if let dt = dateTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            parts.append("datetime:\(formatter.string(from: dt))")
        }
        if let loc = location {
            parts.append("location:\(loc.latitude),\(loc.longitude)")
        }
        return parts.joined(separator: "|")
    }
}

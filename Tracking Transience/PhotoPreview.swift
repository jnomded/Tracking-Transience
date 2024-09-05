//
//  PhotoPreview.swift
//  Tracking Transience
//
//  Created by James Edmond on 9/4/24.
//

import SwiftUI

struct PhotoPreviewView: View {
    let image: UIImage
    var onUsePhoto: (UIImage) -> Void
    var onRetake: () -> Void
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
            
            HStack {
                Button(action: {
                    onUsePhoto(image)
                }) {
                    Text("Use Photo")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    onRetake()
                }) {
                    Text("Retake")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

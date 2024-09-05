//
//  Photo.swift
//  Tracking Transience
//
//  Created by James Edmond on 9/4/24.
//

import SwiftData
import SwiftUI

@Model
class Photo: Identifiable {
    var id = UUID()
    var image: Data // Store image as Data
    var timestamp: Date
    
    init(image: UIImage, timestamp: Date) {
        self.image = image.jpegData(compressionQuality: 1.0) ?? Data()
        self.timestamp = timestamp
    }
}
